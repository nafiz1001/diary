# Functional specification

One section per feature.

## UC-SUB: Submit an entry

Requirements: REQ-SUB-001 to REQ-SUB-006.
Scenarios: `../features/submit.feature`.

**Actor:** the user.

**Precondition:** the user has the submit page open.

**Main flow**

1. The user types text in the form.
2. The user sends the form.
3. The system checks the text (rule BR-SUB-1).
4. The system reads the current time in UTC.
5. The system stores a new entry with the text and that time.
6. The system shows an empty form and the message "Entry saved."

**Alternative flows**

- 3a. The text is whitespace only. The system stores nothing. The system shows the form with the typed text and the message "Write some text before you submit." (REQ-SUB-002)
- 5a. The store fails. The system shows the form with the typed text and the message "The entry was not saved. Try again." (REQ-SUB-006)
- 2a. A submission is already in progress for this form. The system ignores the second send. (REQ-SUB-004)

**Postcondition (success):** the diary has one more entry. The entry text equals the typed text. The creation instant is the time of step 4.

### Business rules

| ID | Rule |
|----|------|
| BR-SUB-1 | A text is valid when it has at least one character that is not whitespace. |
| BR-SUB-2 | The system does not trim the text, collapse spaces or change line breaks. (REQ-SUB-005) |
| BR-SUB-3 | The creation instant comes from the system clock, never from the user. |
| BR-SUB-4 | The system gives the entry an id. The id is unique and never changes. |

### Error cases

| Case | Reason code | Outcome |
|------|-------------|---------|
| Text is whitespace only | `empty_text` | Nothing stored. Form keeps the text. |
| Store fails | `store_unavailable` | Nothing stored. Form keeps the text. |

## UC-BRW: Browse entries

Requirements: REQ-BRW-001 to REQ-BRW-009, REQ-NFR-002, REQ-NFR-003, REQ-NFR-006.
Scenarios: `../features/browse.feature`.

**Actor:** the user.

**Main flow**

1. The user opens the viewer, with or without `limit` and `offset`.
2. The system reads the total number of entries.
3. The system clamps `limit` and `offset` (TS-PAGE-1 to TS-PAGE-5).
4. The system reads that page of entries, newest first.
5. The system shows the total, the entries and the paging links.
6. For each entry the system shows the creation instant in the display zone as `YYYY-MM-DD (Ddd) HH:MM:SS`, the text as plain text with its line breaks and spaces kept, and a link to the update page.

**Alternative flows**

- 5a. The diary has no entry. The system shows "No entries yet." and no paging links. (REQ-BRW-009)
- 1a. The user sets `limit` and `offset` in the viewer controls. The system acts as in step 1. (REQ-BRW-008)

**Postcondition:** the system has changed nothing.

### Business rules

| ID | Rule |
|----|------|
| BR-BRW-1 | The order is creation instant descending, then id descending. |
| BR-BRW-2 | The "next" link shows while offset plus limit is less than the total. Its offset is offset plus limit. |
| BR-BRW-3 | The "latest" and "previous" links show while the offset is above 0. Latest has offset 0. Previous has offset minus limit, not below 0. |
| BR-BRW-4 | The weekday in the time text is the three-letter English abbreviation of the date in the display zone: Mon, Tue, Wed, Thu, Fri, Sat, Sun. |
| BR-BRW-5 | Links keep the effective `limit`. |

### Error cases

A value out of range is not an error. The system clamps it. A value that is not an integer counts as not given.
If the entry store fails, the system shows a failure message and no entries. The reason code is `store_unavailable`.

## UC-UPD: Update an entry

Requirements: REQ-UPD-001 to REQ-UPD-008, REQ-NFR-005.
Scenarios: `../features/update.feature`.

**Actor:** the user.

**Precondition:** the user has the viewer open and follows the update link of an entry.

**Main flow**

1. The user opens the update page of entry `id`.
2. The system finds the entry and shows a form that holds its text.
3. The user changes the text and sends the form.
4. The system checks the text (BR-SUB-1).
5. The system reads the current time in UTC.
6. The system stores the new text and the update instant.
7. The system shows the form with the new text and the message "Entry updated."

**Alternative flows**

- 2a, 3a. No entry has that id. The system answers "not found" and changes nothing. (REQ-UPD-003)
- 4a. The text is whitespace only. The system changes nothing. It shows the form with the typed text and the message "Write some text before you update." (REQ-UPD-004)
- 6a. The store fails. The system changes nothing. It shows the form with the typed text and the message "The entry was not updated. Try again." (REQ-UPD-007)
- 3b. An update is already in progress for this form. The system ignores the second send. (REQ-UPD-006)

**Postcondition (success):** the entry has the new text and a new update instant. Its id and creation instant are the same. No other entry changed.

### Business rules

| ID | Rule |
|----|------|
| BR-UPD-1 | An update uses the text rules of submit: BR-SUB-1 and BR-SUB-2. |
| BR-UPD-2 | An update never changes the id or the creation instant. |
| BR-UPD-3 | An update that sets the same text as before is valid. It still sets the update instant. |

### Error cases

| Case | Reason code | Outcome |
|------|-------------|---------|
| No entry has that id | `not_found` | Nothing changed. |
| Text is whitespace only | `empty_text` | Nothing changed. Form keeps the text. |
| Store fails | `store_unavailable` | Nothing changed. Form keeps the text. |

## UC-EXP: Export entries

Requirements: REQ-EXP-001 to REQ-EXP-010, REQ-NFR-002.
Scenarios: `../features/export.feature`.

**Actor:** the user.

**Main flow**

1. The user opens the export page. The system shows the form: "created since" date, order (ascending chosen), format.
2. The user enters a date, chooses an order and a format, and sends the form.
3. The system checks the date (TS-DATE-1, TS-DATE-2) and the format.
4. The system converts the date to an Instant (TS-DATE-3).
5. The system reads every entry created at or after that Instant, in the chosen order.
6. The system writes the file in the chosen format (`technical-spec.md`, grammar and escape table).
7. The system sends the file as an attachment.

**Alternative flows**

- 3a. The date or the format is missing or invalid. The system shows the export form with a message and sends no file. (REQ-EXP-009)
- 5a. No entry matches. The system sends a file that has only the header rows. (REQ-EXP-010)
- 2a. The user gives no order. The system uses ascending. (REQ-EXP-003)

**Postcondition:** the system has changed nothing.

### Business rules

| ID | Rule |
|----|------|
| BR-EXP-1 | Ascending means oldest first. Equal instants are ordered by id, lowest first. Descending is the exact reverse. |
| BR-EXP-2 | The export holds the text of each entry after escaping (escape table). The export can be read back without loss. |
| BR-EXP-3 | The system has one export route. The legacy second route for tab-separated files is dropped. |

### Error cases

| Case | Reason code | Outcome |
|------|-------------|---------|
| Date missing | `invalid_date` | Export form with a message. No file. |
| Date not valid | `invalid_date` | Export form with a message. No file. |
| Format missing or unknown | `invalid_format` | Export form with a message. No file. |
| Store fails | `store_unavailable` | Failure message. No file. |

## UC-IMP: Import the legacy store

Requirements: REQ-IMP-001 to REQ-IMP-007.
Scenarios: `../features/import.feature`.
State machine: `state-machines.md`, "Legacy import".

**Actor:** the operator, with a command-line tool. The tool needs the path of the legacy file and uses the configured `database_location` for the new store.

**Precondition:** the legacy file exists. The new store has no entry.

**Main flow**

1. The operator runs the tool with the path of the legacy file.
2. The system opens the new store (it creates the schema when the store is new).
3. The system checks that the new store has no entry.
4. The system opens the legacy file read-only and checks that it has the entry table.
5. The system starts one transaction in the new store.
6. For each legacy row, in id order, the system checks the row (see "Invalid entry" in the technical specification) and inserts an entry with the same id, the same text, the creation instant read as UTC and the update instant equal to the creation instant.
7. The system commits the transaction.
8. The system reports the number of entries copied.

**Alternative flows**

- 3a. The new store has an entry. The system refuses and changes nothing. Reason `target_not_empty`. (REQ-IMP-002)
- 4a. The legacy file is missing or unreadable. The system fails. Reason `legacy_unreadable`. (REQ-IMP-003)
- 4b. The legacy file has no entry table. The system fails. Reason `legacy_table_missing`. (REQ-IMP-003)
- 6a. A legacy row is invalid, or an insert fails. The system rolls back the transaction and fails. Reason `entry_invalid` for an invalid row, `target_unavailable` for a store failure. (REQ-IMP-005)

**Postcondition (success):** the new store holds one entry for each legacy row. The legacy file is the same as before (REQ-IMP-007).

### Business rules

| ID | Rule |
|----|------|
| BR-IMP-1 | The import is all or nothing. |
| BR-IMP-2 | The import keeps ids. The new store continues from the highest id. |
| BR-IMP-3 | The import copies the text of every row unchanged, also when it is empty or whitespace only (TS-TEXT-5). |
| BR-IMP-4 | The import does not run on a store that has an entry. This also stops a second import. |
| BR-IMP-5 | A legacy store with no row is valid. The system copies 0 entries and reports 0. |

### Error cases

| Case | Reason code |
|------|-------------|
| New store has an entry | `target_not_empty` |
| Legacy file missing or unreadable | `legacy_unreadable` |
| Legacy file has no entry table | `legacy_table_missing` |
| A legacy row is invalid | `entry_invalid` |
| New store fails | `target_unavailable` |
