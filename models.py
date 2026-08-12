from datetime import datetime, timezone
from typing import Any

from sqlalchemy import Dialect
from sqlmodel import Field, SQLModel, Session, create_engine
import sqlalchemy.types as types


class DateTimeWithTZInfo(types.TypeDecorator[datetime]):
    """Ensures datetimes read from SQLite always carry tzinfo=timezone.utc."""

    impl = types.DateTime(timezone=True)
    cache_ok = True

    def process_result_value(self, value: Any | None, dialect: Dialect):
        if isinstance(value, datetime):
            return value.replace(tzinfo=timezone.utc)
        return value


class DiaryEntry(SQLModel, table=True):
    __tablename__ = "diary_entries"  # pyright: ignore[reportAssignmentType]
    __table_args__ = {"extend_existing": True}

    id: int | None = Field(default=None, primary_key=True)
    entry_text: str = Field(description="Main body content of the diary entry")
    created_at: datetime = Field(
        description=f"Diary entry time in UTC",
        sa_type=DateTimeWithTZInfo,
        default_factory=lambda: datetime.now(timezone.utc),
    )


sqlite_file_name = "sqlite.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"
ENGINE = create_engine(sqlite_url)


def create_all():
    SQLModel.metadata.create_all(ENGINE)


def get_db_session():
    """Dependency to get an SQLModel Session per request."""
    with Session(ENGINE) as session:
        yield session


if __name__ == "__main__":
    from sqlmodel import *  # pyright: ignore[reportWildcardImportFromLibrary]

    session = Session(ENGINE)
    create_all()
