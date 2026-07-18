from datetime import datetime
from pathlib import Path
import sys
import sqlite3

con = sqlite3.connect("sqlite.db")

for path in Path(sys.argv[1]).iterdir():
    if not path.name.endswith(".org"):
        continue

    content = path.read_text()
    for top_entry in content.split("* ["):
        top_entry = top_entry.strip()
        if not top_entry:
            continue

        date_time = top_entry[:top_entry.index("]")]
        date_time = datetime.strptime(date_time, "%Y-%m-%d %a %H:%M")
        date_time = date_time.strftime("%Y-%m-%d %H:%M:%S")

        items_buf = top_entry[top_entry.index("]")+1:]
        items = items_buf.split("\n- ")

        for item in items:
            item = item.strip()
            if not item:
                continue
            con.execute(
                "INSERT INTO diary_entries (entry_text, created_at) VALUES (?, ?)", (item, date_time)
            )
            con.commit()
