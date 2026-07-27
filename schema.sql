CREATE TABLE IF NOT EXISTS diary_entries (
    -- Unique identifier for each entry
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Main body content of the diary entry
    entry_text TEXT NOT NULL,

    -- Diary entry time (automatically defaults to UTC)
    created_at TEXT NOT NULL
);
