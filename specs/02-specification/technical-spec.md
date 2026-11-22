# Technical specification

Rules that apply to every feature. Functional behaviour is in `functional-spec.md`.

## Configuration

| Key | Meaning | Default | Requirement |
|-----|---------|---------|-------------|
| `database_location` | Path of the entry store file. | `diary.db` in the working directory | REQ-NFR-004 |
| `display_zone` | Name of the display zone, from the IANA time zone database. | `America/Montreal` | REQ-NFR-002 |
| `listen_address` | Host and port where the system accepts requests. | `127.0.0.1:8000` | (deployment) |

A key is set by a command-line option or an environment variable. The implementation chooses the names.
An unknown `display_zone` stops the system at start with an error that names the key.

## Time rules

| ID | Rule |
|----|------|
| TS-TIME-1 | The system keeps every Instant in UTC (REQ-NFR-001). |
| TS-TIME-2 | The system sets the creation instant when it stores the entry. |
| TS-TIME-3 | The creation instant has a resolution of at least one second. The store keeps microseconds. |
| TS-TIME-4 | The system never changes the creation instant of an entry (REQ-UPD-008). |
| TS-TIME-5 | The update instant equals the creation instant until the first update. Each update sets it to the current time. |
| TS-TIME-6 | The system converts an Instant to the display zone only to show it or to write it in an export. |

## Date input rules

| ID | Rule |
|----|------|
| TS-DATE-1 | A date input has the form `YYYY-MM-DD`. A time or an offset in the input makes it invalid. This is narrower than legacy, which also accepted a time. Chosen in the phase 3 review to keep the rules simple. |
| TS-DATE-2 | A date is valid when it exists in the Gregorian calendar. `2026-02-30` is invalid. |
| TS-DATE-3 | The Instant of a date is the first instant of that date in the display zone. If midnight does not exist on that date in the zone, use the first instant of the date that exists. |
| TS-DATE-4 | An export includes an entry when its creation instant is greater than or equal to the Instant of the date. |

## Text rules

| ID | Rule |
|----|------|
| TS-TEXT-1 | Entry text is a sequence of Unicode characters. |
| TS-TEXT-2 | The system stores the sequence unchanged, including line breaks, tabs and leading and trailing whitespace. |
| TS-TEXT-3 | Whitespace means space (U+0020), tab (U+0009), line feed (U+000A) and carriage return (U+000D). |
| TS-TEXT-4 | The system sets no maximum text length in version 1. |
| TS-TEXT-5 | The rule "not whitespace only" applies to submit and update. It does not apply to entries that the import copies. |
| TS-TEXT-6 | The system shows entry text as plain text. It turns every character that a page language reads as markup into plain characters (REQ-NFR-003). |

## Paging rules (REQ-BRW-002, REQ-BRW-004)

| ID | Rule |
|----|------|
| TS-PAGE-1 | `limit` and `offset` are integers in base 10. A value that is not an integer counts as not given. |
| TS-PAGE-2 | `limit` not given means 10. `offset` not given means 0. |
| TS-PAGE-3 | `limit` below 1 becomes 1. `limit` above 100 becomes 100. |
| TS-PAGE-4 | `offset` below 0 becomes 0. `offset` above total minus 1 becomes total minus 1. For an empty diary `offset` is 0. |
| TS-PAGE-5 | The system clamps first. Then it reads the entries with the effective values. |
| TS-PAGE-6 | The next page starts at offset plus limit. It exists when offset plus limit is less than the total. |
| TS-PAGE-7 | The previous page starts at offset minus limit, not below 0. |

## Export rules

### Escape table (REQ-EXP-006, REQ-EXP-007)

The system replaces each character of the entry text with the escape in this table.
It replaces each character once, from left to right. It does not escape an escape again.

| Character | Code point | Markdown export | Tab-separated export |
|-----------|-----------|-----------------|----------------------|
| backslash | U+005C | backslash backslash | backslash backslash |
| pipe | U+007C | backslash pipe | no escape |
| line feed | U+000A | backslash `n` | backslash `n` |
| carriage return | U+000D | backslash `r` | backslash `r` |
| tab | U+0009 | backslash `t` | backslash `t` |

All other characters, including the double quote, are written as they are. No field is quoted.

### Row and file rules

| ID | Rule |
|----|------|
| TS-EXP-1 | Every line of an export, including the last, ends with a line feed. |
| TS-EXP-2 | The text encoding is UTF-8 with no byte order mark. |
| TS-EXP-3 | The system sends the file as an attachment with the file name from the grammar below. |
| TS-EXP-4 | The timestamp of a row is the creation instant in the display zone. |

### Grammar (ABNF, RFC 5234)

```abnf
markdown-export = md-header md-separator *md-row
md-header       = "|created_at|entry_text|" LF
md-separator    = "|-|-|" LF
md-row          = "|" timestamp "|" md-text "|" LF

tsv-export      = tsv-header *tsv-row
tsv-header      = "created_at" HTAB "entry_text" LF
tsv-row         = timestamp HTAB tsv-text LF

timestamp       = date "T" time offset
date            = 4DIGIT "-" 2DIGIT "-" 2DIGIT
time            = 2DIGIT ":" 2DIGIT ":" 2DIGIT
offset          = ("+" / "-") 2DIGIT 2DIGIT

md-text         = *( md-plain / md-escape )
md-plain        = <any character except %x5C, %x7C, %x0A, %x0D, %x09>
md-escape       = %x5C ( %x5C / %x7C / "n" / "r" / "t" )

tsv-text        = *( tsv-plain / tsv-escape )
tsv-plain       = <any character except %x5C, %x0A, %x0D, %x09>
tsv-escape      = %x5C ( %x5C / "n" / "r" / "t" )

LF              = %x0A
HTAB            = %x09
```

File names and media types:

| Format | File name | Media type |
|--------|-----------|-----------|
| Markdown | `diary.md` | `text/markdown` |
| Tab-separated | `diary.tsv` | `text/tab-separated-values` |

## Legacy store format (for the import)

| Item | Rule |
|------|------|
| Entry table | A table named `diary_entries`. |
| Columns | `id` (integer), `entry_text` (text), `created_at` (text). |
| Instant text | `YYYY-MM-DD HH:MM:SS`, optionally followed by `.` and 1 to 6 digits. No zone marker. UTC (REQ-IMP-006). |
| Invalid entry | A row whose `entry_text` or `created_at` is null, or whose `created_at` does not match the form above, or whose `id` is null. |

Details of the import are in `functional-spec.md` (UC-IMP) and, from phase 5, `../04-design/data/legacy-import.md`.

## Non-functional needs

| ID | Need |
|----|------|
| TS-NFR-1 | Every page and form works with no script support in the browser (ADR-0004). |
| TS-NFR-2 | The system confirms a write only after the entry store holds it (REQ-NFR-005). |
| TS-NFR-3 | The system answers any page request in under 1 second on a personal machine with a diary of 100000 entries (REQ-NFR-006). |
| TS-NFR-4 | An update or a submit is atomic. A failure leaves the entry store as it was. |

## Scenario step conventions

1. Step text is domain language. It names no page element, route or status code.
2. Tokens in step text, table cells and doc strings: `{space}` is a space, `{tab}` is a tab, `{newline}` is a line feed, `{return}` is a carriage return, `{backslash}` is a backslash and `{pipe}` is a pipe character. This keeps whitespace visible and avoids the escape rules of Gherkin tables (which trim cells and read a backslash followed by `n`, `|` or a backslash as an escape). The runner replaces the tokens before it compares or sends text.
3. A `@manual` scenario is skipped by the runner.
4. `Given the diary has N numbered entries`: entry k (k = 1 to N) has the id k, the text `Entry k` and the creation instant 2026-01-01 00:00:00 UTC plus k minutes.
5. `Given the diary has these entries:` takes a table with columns `text` and `created_at` (UTC, `YYYY-MM-DD HH:MM:SS`). Ids are 1, 2, 3 in table order.
6. `Given an entry created at "T" UTC with the text "X"` adds one entry. Its id follows the highest id in the diary, or is 1.
7. A doc string that gives file content has one line per row. The runner compares it with the file content in which the last line feed is removed.
8. A scenario that gives no display zone uses the default, `America/Montreal`. In winter its offset is -0500. In summer it is -0400.
9. `Given a legacy store with these entries:` takes a table with columns `id`, `text` and `created_at`. The cell of `created_at` is stored as given, as text.
10. `Given an empty diary` means a new entry store with no entry. For import scenarios it is the new store.
11. The effective values of the viewer (`limit` and `offset`) are the values after clamping (TS-PAGE-3 and TS-PAGE-4).
12. `the system answers "not found"` means the user is told that the entry does not exist, whatever the form of the answer.
