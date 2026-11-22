# Requirements

EARS statements. Each ID is stable. See `../README.md` for the patterns.
Legacy behaviour is the base. A line that starts with "Fixes legacy" marks a changed defect.

## Submit (REQ-SUB)

| ID | Pattern | Requirement |
|----|---------|-------------|
| REQ-SUB-001 | Event-driven | When the user submits entry text, the system shall store a new entry with that text and the current time in UTC. |
| REQ-SUB-002 | Unwanted behaviour | If the entry text is empty or has only whitespace, then the system shall reject the submission, store no entry and keep the text in the form. Fixes legacy: the legacy implementation stores whitespace-only text (it rejects only the exactly empty text). |
| REQ-SUB-003 | Event-driven | When the system has stored an entry, the system shall show an empty form and tell the user that the entry was saved. |
| REQ-SUB-004 | State-driven | While a submission is in progress, the system shall prevent a second submission from the same form. |
| REQ-SUB-005 | Ubiquitous | The system shall store the entry text exactly as the user entered it, with no trimming and no change of line breaks. |
| REQ-SUB-006 | Unwanted behaviour | If the system cannot store the entry, then the system shall tell the user that the submission failed and keep the text in the form. |

## Browse (REQ-BRW)

| ID | Pattern | Requirement |
|----|---------|-------------|
| REQ-BRW-001 | Event-driven | When the user opens the viewer, the system shall show one page of entries ordered by creation instant, newest first. Entries with the same instant are ordered by id, highest first. |
| REQ-BRW-002 | Ubiquitous | The system shall use a page size (`limit`) of 10 and a start position (`offset`) of 0 when the user gives none. |
| REQ-BRW-003 | Ubiquitous | The system shall show each entry with its creation instant in the display zone as `YYYY-MM-DD (Ddd) HH:MM:SS`, its text with line breaks and spaces kept, and a link to update it. |
| REQ-BRW-004 | Unwanted behaviour | If `limit` or `offset` is out of range, then the system shall clamp it into range before it reads entries. Range of `limit`: 1 to 100. Range of `offset`: 0 to the total minus 1, or 0 when the diary is empty. Fixes legacy: the legacy implementation reads entries with the unclamped offset. |
| REQ-BRW-005 | Ubiquitous | The system shall show the total number of entries on every page of the viewer. |
| REQ-BRW-006 | State-driven | While more entries follow the shown page, the system shall show a link to the next page. The next page starts at offset plus limit. Fixes legacy: the legacy implementation shows "Next" on the last page. |
| REQ-BRW-007 | State-driven | While the shown page does not start at offset 0, the system shall show a link to the latest page (offset 0) and a link to the previous page (offset minus limit, not below 0). |
| REQ-BRW-008 | Optional feature | Where the user sets `limit` or `offset` in the viewer controls, the system shall show the page for those values. |
| REQ-BRW-009 | Unwanted behaviour | If the diary has no entries, then the system shall show the message "No entries yet." and no paging links. |

## Update (REQ-UPD)

| ID | Pattern | Requirement |
|----|---------|-------------|
| REQ-UPD-001 | Event-driven | When the user opens the update page of an existing entry, the system shall show a form that holds the current text of that entry. |
| REQ-UPD-002 | Event-driven | When the user submits valid text for an existing entry, the system shall replace the text, set the update instant to the current time in UTC, show the form with the new text and tell the user that the entry was updated. |
| REQ-UPD-003 | Unwanted behaviour | If the user requests an entry id that does not exist, then the system shall respond "not found" and change nothing. Fixes legacy: the legacy implementation fails with a server error on save. |
| REQ-UPD-004 | Unwanted behaviour | If the new text is empty or has only whitespace, then the system shall reject the update, keep the stored text and keep the text in the form. Fixes legacy: the legacy implementation stores whitespace-only text. |
| REQ-UPD-005 | Ubiquitous | The system shall store the updated text exactly as the user entered it. |
| REQ-UPD-006 | State-driven | While an update is in progress, the system shall prevent a second submission from the same form. |
| REQ-UPD-007 | Unwanted behaviour | If the system cannot store the update, then the system shall tell the user that the update failed, keep the stored text and keep the text in the form. |
| REQ-UPD-008 | Ubiquitous | The system shall never change the id or the creation instant of an entry. |

## Export (REQ-EXP)

| ID | Pattern | Requirement |
|----|---------|-------------|
| REQ-EXP-001 | Event-driven | When the user opens the export page, the system shall show a form with a "created since" date, an order (ascending or descending, ascending chosen) and a format (Markdown or tab-separated). |
| REQ-EXP-002 | Event-driven | When the user requests an export with a date and a format, the system shall deliver a file with every entry created at or after the start of that date in the display zone. |
| REQ-EXP-003 | Optional feature | Where the user chooses descending order, the system shall write entries newest first. Otherwise the system shall write entries oldest first. |
| REQ-EXP-004 | Event-driven | When the system writes a Markdown export, the system shall write the header row `\|created_at\|entry_text\|`, the separator row `\|-\|-\|`, then one row per entry. The file name is `diary.md`. The media type is `text/markdown`. |
| REQ-EXP-005 | Event-driven | When the system writes a tab-separated export, the system shall write the header row `created_at`, tab, `entry_text`, then one row per entry. The file name is `diary.tsv`. The media type is `text/tab-separated-values`. |
| REQ-EXP-006 | Event-driven | When the system writes a Markdown export, the system shall escape these characters in the entry text: backslash as two backslashes, the pipe character as backslash and pipe, line feed as backslash and `n`, carriage return as backslash and `r`, tab as backslash and `t`. Fixes legacy: the legacy implementation does not escape backslash or the pipe character. |
| REQ-EXP-007 | Event-driven | When the system writes a tab-separated export, the system shall escape backslash, line feed, carriage return and tab in the entry text as in REQ-EXP-006 and shall not quote any field. Fixes legacy: the legacy implementation did not escape backslash and its writer quoted fields that hold a double quote. |
| REQ-EXP-008 | Ubiquitous | The system shall write the creation instant of each exported entry in the display zone as `YYYY-MM-DDTHH:MM:SS` followed by the offset as `+hhmm` or `-hhmm`. |
| REQ-EXP-009 | Unwanted behaviour | If the date is missing or not a valid date, or the format is missing or unknown, then the system shall show the export form with a message and deliver no file. |
| REQ-EXP-010 | Unwanted behaviour | If no entry matches, then the system shall deliver a file that has only the header rows. |

## Import (REQ-IMP)

The operator runs the import from a command-line tool. The import runs once.

| ID | Pattern | Requirement |
|----|---------|-------------|
| REQ-IMP-001 | Event-driven | When the operator runs the import with a legacy store file, the system shall copy every legacy entry into the new store with the same id, the same text and the same creation instant, and shall set the update instant equal to the creation instant. |
| REQ-IMP-002 | Unwanted behaviour | If the new store already holds an entry, then the system shall refuse the import and change nothing. |
| REQ-IMP-003 | Unwanted behaviour | If the legacy file is missing, unreadable or has no legacy entry table, then the system shall fail with a reason and change nothing. |
| REQ-IMP-004 | Event-driven | When the import ends, the system shall report the number of entries copied. |
| REQ-IMP-005 | Unwanted behaviour | If any legacy entry cannot be copied, then the system shall undo the whole import and report the failure. |
| REQ-IMP-006 | Ubiquitous | The system shall read a legacy creation instant that has no zone marker as UTC. |
| REQ-IMP-007 | Ubiquitous | The system shall not change the legacy file. |

## Non-functional (REQ-NFR)

| ID | Pattern | Requirement |
|----|---------|-------------|
| REQ-NFR-001 | Ubiquitous | The system shall store every instant in UTC. |
| REQ-NFR-002 | Optional feature | Where the display zone is configured, the system shall use it to show instants and to read dates. Otherwise the system shall use `America/Montreal`. |
| REQ-NFR-003 | Ubiquitous | The system shall show entry text as plain text. The system shall never read entry text as markup. |
| REQ-NFR-004 | Ubiquitous | The system shall read the location of the entry store from configuration. |
| REQ-NFR-005 | Ubiquitous | The system shall confirm a write to the user only after the entry store holds it. |
| REQ-NFR-006 | State-driven | While the diary holds 100000 entries, the system shall answer a request for any page in less than 1 second on a personal machine. |
