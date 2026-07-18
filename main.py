import hashlib
import os
import sqlite3
from contextlib import asynccontextmanager
from datetime import datetime
from threading import RLock
from typing import TypedDict

import uvicorn
from fastapi import FastAPI, Request, Response, Form, Depends, status
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates

DB_NAME = "sqlite.db"


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
    db.execute("INSERT INTO diary_entries (entry_text) VALUES (?)", (submission,))
    db.commit()
    # Redirect back to index with 303 See Other
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)


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
        "SELECT created_at, entry_text FROM diary_entries ORDER BY created_at DESC LIMIT ? OFFSET ?",
        (limit, offset),
    )
    rows = cursor.fetchall()

    Entry = TypedDict(
        "Entry",
        {
            "datetime": datetime,
            "note": str,
        },
    )
    entries: list[Entry] = []
    for row in rows:
        try:
            # Parse time mimicking Go's time.Parse(time.DateTime)
            dt = datetime.strptime(row["created_at"], "%Y-%m-%d %H:%M:%S")
            # In Python 3.6+, datetime.astimezone() converts to local time
            dt = dt.astimezone()
        except ValueError:
            dt = datetime.now()

        entries.append({"datetime": dt, "note": row["entry_text"]})

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


@app.get("/style.css")
async def style(request: Request):
    if not os.path.exists("style.css"):
        return Response(status_code=status.HTTP_404_NOT_FOUND)

    with open("style.css", "rb") as f:
        content = f.read()

    etag = generate_etag(content)

    if request.headers.get("if-none-match") == etag:
        return Response(status_code=status.HTTP_304_NOT_MODIFIED)

    headers = {
        "Cache-Control": "max-age=3600, must-revalidate",
        "ETag": etag,
    }
    return Response(
        content=content, media_type="text/css; charset=utf-8", headers=headers
    )


if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
