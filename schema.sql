CREATE TABLE IF NOT EXISTS diary_entries (
    -- Unique identifier for each entry
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Main body content of the diary entry
    entry_text TEXT NOT NULL,

    -- Diary entry time (in UTC in ISO 8601 format "%Y-%m-%dT%H:%M:%SZ")
    created_at TEXT NOT NULL
);
