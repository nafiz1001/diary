# Legacy import

One-time copy of the legacy store into the new store. Behaviour: `../../02-specification/functional-spec.md` (UC-IMP).
States: `../../02-specification/state-machines.md` ("Legacy import"). Decision: ADR-0007.
Scenarios: `../../features/import.feature`.

## Source and target

| | Legacy store | New store |
|---|--------------|-----------|
| Table | `diary_entries` | `entries` (`schema.sql`) |
| Access | read-only | read and write, one transaction |

## Column mapping

| Legacy column | New column | Rule |
|---------------|-----------|------|
| `id` | `id` | Kept. A null id is invalid (`entry_invalid`). |
| `entry_text` | `entry_text` | Copied unchanged, also when empty or whitespace only (BR-IMP-3, TS-TEXT-5). A null text is invalid. |
| `created_at` | `created_at` | Read as UTC text (REQ-IMP-006), written in the store form of `schema.sql`. A null or unparseable value is invalid. |
| (none) | `updated_at` | Set equal to `created_at` (REQ-IMP-001). |

## Legacy instant text

```abnf
legacy-instant = date SP time [ "." 1*6DIGIT ]
date           = 4DIGIT "-" 2DIGIT "-" 2DIGIT
time           = 2DIGIT ":" 2DIGIT ":" 2DIGIT
```

The date and time must exist (month 1 to 12, day valid for the month, hour 0 to 23, minute and second 0 to 59).
A missing fraction means zero. A fraction with fewer than 6 digits is padded on the right with zeros.
Any other form (for example a `T` separator, a zone marker or a date alone) is invalid.

## Procedure

1. Open the new store at `database_location`. Create the schema if the store is new.
2. If `count()` is above 0, end with `Refused(target_not_empty)`.
3. Open the legacy file read-only. If it cannot be opened or read, end with `Failed(legacy_unreadable)`.
4. If the legacy file has no table `diary_entries`, end with `Failed(legacy_table_missing)`.
5. Begin one transaction on the new store.
6. Read the legacy rows ordered by `id`. For each row:
   1. Check the row. If it is invalid, roll back and end with `Failed(entry_invalid)`.
   2. Insert `(id, entry_text, created_at, updated_at = created_at)`.
   3. If the insert fails, roll back and end with `Failed(target_unavailable)`.
7. Commit. If the commit fails, end with `Failed(target_unavailable)`.
8. Make the identity column continue after the highest imported id (BR-IMP-2).
9. End with `Done(n)`. Print `imported: n`.

A legacy file that has the table and no row ends with `Done(0)` (BR-IMP-5).
Two rows with the same id cannot occur in the legacy primary key. If they occur, the insert fails and the import ends with `Failed(target_unavailable)`.

## Failure cases

| Case | Result | New store after | Legacy file after |
|------|--------|-----------------|-------------------|
| New store has an entry | `Refused(target_not_empty)`, exit 2 | unchanged | unchanged |
| Legacy file missing or unreadable | `Failed(legacy_unreadable)`, exit 1 | unchanged | unchanged |
| No `diary_entries` table | `Failed(legacy_table_missing)`, exit 1 | unchanged | unchanged |
| A row is invalid | `Failed(entry_invalid)`, exit 1 | unchanged (rolled back) | unchanged |
| The new store fails | `Failed(target_unavailable)`, exit 1 | unchanged (rolled back) | unchanged |
| Second run | `Refused(target_not_empty)`, exit 2 | unchanged | unchanged |

"Unchanged" for the new store means it holds no entry. A new store file may exist with an empty schema.

## Checks after a run on real data

1. The count of rows in `entries` equals the count of rows in `diary_entries`.
2. For a sample of ids (first, last and five others) the text, `created_at` and `updated_at` match the rules above.
3. The viewer shows the newest entries with the same times that the legacy viewer shows in the display zone.
4. The legacy file has the same checksum as before the run.

Run the first import on a copy of the legacy file. Keep the original as a backup.
