# Requirements

EARS statements. Each ID is stable. See `../README.md` for the patterns.
This file holds the requirements written so far. Phase 2 adds the other areas.

## Submit (REQ-SUB)

| ID | Pattern | Requirement |
|----|---------|-------------|
| REQ-SUB-001 | Event-driven | When the user submits entry text, the system shall store a new entry with that text and the current time in UTC. |
| REQ-SUB-002 | Unwanted behaviour | If the entry text is empty or has only whitespace, then the system shall reject the submission, store no entry and keep the text in the form. (Fixes legacy: the legacy implementation stores empty entries.) |
| REQ-SUB-003 | Event-driven | When the system has stored an entry, the system shall show an empty form and tell the user that the entry was saved. |
| REQ-SUB-004 | State-driven | While a submission is in progress, the system shall prevent a second submission from the same form. |
| REQ-SUB-005 | Ubiquitous | The system shall store the entry text exactly as the user entered it, with no trimming and no change of line breaks. |
| REQ-SUB-006 | Unwanted behaviour | If the system cannot store the entry, then the system shall tell the user that the submission failed and keep the text in the form. |
