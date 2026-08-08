import csv
import hashlib
import io
import os
import sqlite3
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from threading import RLock
from typing import Any, TypedDict
from zoneinfo import ZoneInfo

import uvicorn
from fastapi import (
    FastAPI,
    Request,
    Response,
    Form,
    Depends,
    status,
)
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

DB_NAME = "sqlite.db"

tzinfo = ZoneInfo("America/Montreal")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Execute schema.sql on startup
    if os.path.exists("schema.sql"):
        with sqlite3.connect(DB_NAME) as conn:
            with open("schema.sql", "r") as f:
                conn.executescript(f.read())
    yield


app = FastAPI(lifespan=lifespan)

# Note: Jinja2 expects a templates directory.
# We'll point it to the current directory to mimic the Go structure,
# but usually, you'd put these in a "templates" folder.
templates = Jinja2Templates(directory="templates/")


lock = RLock()


def get_db():
    """Dependency to get a database connection per request."""
    conn = sqlite3.connect(DB_NAME, check_same_thread=False)
    conn.row_factory = sqlite3.Row  # Allows accessing columns by name
    try:
        lock.acquire()
        yield conn
    finally:
        conn.close()
        lock.release()


def generate_etag(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    # Render template to string to compute ETag
    template = templates.get_template("index.html")
    html_content = template.render()
    content_bytes = html_content.encode("utf-8")

    etag = generate_etag(content_bytes)

    # Check If-None-Match header
    if request.headers.get("if-none-match") == etag:
        return Response(status_code=status.HTTP_304_NOT_MODIFIED)

    return HTMLResponse(
        content=html_content,
        headers={
            "Cache-Control": "max-age=3600, must-revalidate",
            "ETag": etag,
        },
    )


@app.post("/")
async def add_entry(
    submission: str = Form(...), db: sqlite3.Connection = Depends(get_db)
):
    db.execute(
        "INSERT INTO diary_entries (entry_text, created_at) VALUES (?, ?)",
        (
            submission,
            datetime.now(timezone.utc)
            .replace(microsecond=0)
            .strftime("%Y-%m-%dT%H:%M:%SZ"),
        ),
    )
    db.commit()
    # Redirect back to index with 303 See Other
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)


def get_diary_entry(entry_id: int, db: sqlite3.Connection) -> Any:
    cursor = db.cursor()
    cursor.execute(
        "SELECT id, entry_text, created_at FROM diary_entries WHERE id = ?", (entry_id,)
    )
    return cursor.fetchone()


@app.get("/update/{entry_id}", response_class=HTMLResponse)
async def view_entry(
    entry_id: int, request: Request, db: sqlite3.Connection = Depends(get_db)
):
    result = get_diary_entry(entry_id, db)

    if result is None:
        return Response(status_code=status.HTTP_404_NOT_FOUND)

    return templates.TemplateResponse(
        request=request,
        name="update.html",
        context=dict(
            {"id": entry_id, "current": result["entry_text"], "updated": False}
        ),
    )


@app.post("/update/{entry_id}")
async def update_entry(
    entry_id: int,
    request: Request,
    update: str = Form(...),
    db: sqlite3.Connection = Depends(get_db),
):
    db.execute(
        "UPDATE diary_entries SET entry_text = ? WHERE id = ?",
        (update, entry_id),
    )
    db.commit()

    result = get_diary_entry(entry_id, db)
    if result is None:
        return Response(status_code=status.HTTP_400_BAD_REQUEST)

    return templates.TemplateResponse(
        request=request,
        name="update.html",
        context=dict(
            {"id": entry_id, "current": result["entry_text"], "updated": True}
        ),
    )


@app.get("/viewer", response_class=HTMLResponse)
async def viewer(
    request: Request,
    limit: int = 10,
    offset: int = 0,
    db: sqlite3.Connection = Depends(get_db),
):
    cursor = db.cursor()

    # Fetch entries
    cursor.execute(
        "SELECT id, entry_text, created_at FROM diary_entries ORDER BY created_at DESC LIMIT ? OFFSET ?",
        (limit, offset),
    )
    rows = cursor.fetchall()

    Entry = TypedDict(
        "Entry",
        {"datetime": datetime, "note": str, "id": int},
    )
    entries: list[Entry] = []
    for row in rows:
        try:
            dt = datetime.fromisoformat(row["created_at"])

            dt = dt.astimezone(tzinfo)
        except ValueError:
            dt = datetime.now()

        entries.append({"datetime": dt, "note": row["entry_text"], "id": row["id"]})

    # Fetch total count
    cursor.execute("SELECT COUNT(*) FROM diary_entries")
    total = cursor.fetchone()[0] or 0

    # Calculate bounds
    offset = max(min(offset, total - 1), 0) if total > 0 else 0
    next_offset = min(offset + limit, total)
    prev_offset = max(offset - limit, 0)

    Data = TypedDict(
        "Data",
        {
            "limit": int,
            "offset": int,
            "nextOffset": int,
            "prevOffset": int,
            "total": int,
            "entries": list[Entry],
        },
    )
    data: Data = {
        "limit": limit,
        "offset": offset,
        "nextOffset": next_offset,
        "prevOffset": prev_offset,
        "total": total,
        "entries": entries,
    }

    return templates.TemplateResponse(
        request=request, name="viewer.html", context=dict(data)
    )


@app.get("/diary.tsv")
def diary_tsv(
    created_after: datetime,
    db: sqlite3.Connection = Depends(get_db),
):
    cursor = db.cursor()

    if created_after.tzinfo is None:
        # If naive datetime is provided, assume tzinfo
        created_after = created_after.replace(tzinfo=tzinfo)
    created_after = created_after.astimezone(timezone.utc)

    formatted_time = created_after.strftime("%Y-%m-%dT%H:%M:%SZ")

    cursor.execute(
        "SELECT id, entry_text, created_at FROM diary_entries WHERE created_at > ? ORDER BY created_at DESC",
        (formatted_time,),
    )

    output = io.StringIO()
    writer = csv.writer(output, delimiter="\t")
    writer.writerow(["created_at", "entry_text"])
    for row in cursor.fetchall():
        clean_entry_text = (
            row["entry_text"]
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t")
        )
        writer.writerow([row["created_at"], clean_entry_text])

    return Response(
        content=output.getvalue(),
        media_type="text/tab-separated-values",
        headers={"Content-Disposition": 'attachment; filename="diary.tsv"'},
    )


app.mount("/static", StaticFiles(directory="static"), name="static")

if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
