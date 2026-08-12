import csv
import hashlib
import io
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import TypedDict
from zoneinfo import ZoneInfo

from sqlmodel import (
    Session,
    desc,
    func,
    select,
)
import uvicorn
from fastapi import (
    FastAPI,
    HTTPException,
    Request,
    Response,
    Form,
    Depends,
    status,
)
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

import models
from models import DiaryEntry

client_tzinfo = ZoneInfo("America/Montreal")


@asynccontextmanager
async def lifespan(app: FastAPI):
    models.create_all()
    yield


app = FastAPI(lifespan=lifespan)

# Note: Jinja2 expects a templates directory.
# We'll point it to the current directory to mimic the Go structure,
# but usually, you'd put these in a "templates" folder.
templates = Jinja2Templates(directory="templates/")


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
    submission: str = Form(...), session: Session = Depends(models.get_db_session)
):
    session.add(DiaryEntry(entry_text=submission))
    session.commit()
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)


@app.get("/update/{entry_id}", response_class=HTMLResponse)
async def view_entry(
    entry_id: int, request: Request, session: Session = Depends(models.get_db_session)
):
    try:
        diary_entry = session.exec(
            select(DiaryEntry).where(DiaryEntry.id == entry_id)
        ).one()
        return templates.TemplateResponse(
            request=request,
            name="update.html",
            context=dict(
                {
                    "id": diary_entry.id,
                    "current": diary_entry.entry_text,
                    "updated": False,
                }
            ),
        )
    except:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)


@app.post("/update/{entry_id}")
async def update_entry(
    entry_id: int,
    request: Request,
    update: str = Form(...),
    session: Session = Depends(models.get_db_session),
):
    diary_entry = session.exec(
        select(DiaryEntry).where(DiaryEntry.id == entry_id)
    ).one()

    diary_entry.entry_text = update
    session.add(diary_entry)
    session.commit()

    diary_entry = session.exec(
        select(DiaryEntry).where(DiaryEntry.id == entry_id)
    ).one()

    return templates.TemplateResponse(
        request=request,
        name="update.html",
        context=dict(
            {
                "id": diary_entry.id,
                "current": diary_entry.entry_text,
                "updated": True,
            }
        ),
    )


@app.get("/viewer", response_class=HTMLResponse)
async def viewer(
    request: Request,
    limit: int = 10,
    offset: int = 0,
    session: Session = Depends(models.get_db_session),
):
    diary_entries = session.exec(
        select(DiaryEntry)
        .order_by(desc(DiaryEntry.created_at))
        .offset(offset)
        .limit(limit)
    )

    Entry = TypedDict(
        "Entry",
        {"datetime": datetime, "note": str, "id": int},
    )
    entries: list[Entry] = []
    for diary_entry in diary_entries:
        entries.append(
            {
                "datetime": diary_entry.created_at.astimezone(client_tzinfo),
                "note": diary_entry.entry_text,
                "id": diary_entry.id,  # pyright: ignore[reportArgumentType]
            }
        )

    total = session.exec(select(func.count()).select_from(DiaryEntry)).one()

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
    created_since: datetime,
    session: Session = Depends(models.get_db_session),
):
    if created_since.tzinfo is None:
        # If naive datetime is provided, assume client_tzinfo
        created_since = created_since.replace(tzinfo=client_tzinfo)
    created_since = created_since.astimezone(timezone.utc)

    diary_entries = session.exec(
        select(DiaryEntry)
        .where(DiaryEntry.created_at >= created_since)
        .order_by(desc(DiaryEntry.created_at))
    )

    output = io.StringIO()
    writer = csv.writer(output, delimiter="\t")
    writer.writerow(["created_at", "entry_text"])
    for diary_entry in diary_entries:
        clean_entry_text = (
            diary_entry.entry_text.replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t")
        )
        writer.writerow(
            [
                diary_entry.created_at.astimezone(client_tzinfo).strftime(
                    "%Y-%m-%dT%H:%M:%S%z"
                ),
                clean_entry_text,
            ]
        )

    return Response(
        content=output.getvalue(),
        media_type="text/tab-separated-values",
        headers={"Content-Disposition": 'attachment; filename="diary.tsv"'},
    )


app.mount("/static", StaticFiles(directory="static"), name="static")

if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
