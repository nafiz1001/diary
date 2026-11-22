# Functional specification

One section per feature. Phase 3 adds browse, update, export and import.

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
