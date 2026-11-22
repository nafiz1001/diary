# ADR-0007: New schema and one-time legacy import

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The legacy store has one table, `diary_entries`, with `id`, `entry_text` and `created_at`.
The new model needs an update instant (REQ-UPD-002) and has rules on instants and text
that the legacy store does not enforce. The user has real entries in the legacy store.

## Considered options

1. Change the legacy table in place (add a column) and run the new system on the same file.
2. Make the new system read both schemas.
3. Define a new schema in a new store and copy the legacy entries once.

## Decision outcome

Chosen option: 3.

- The new table is `entries` with `id`, `entry_text`, `created_at` and `updated_at`
  (`../../04-design/data/schema.sql`, completed in phase 5).
- A command-line import tool copies every legacy row into an empty new store in one transaction
  (UC-IMP, REQ-IMP-001 to REQ-IMP-007).
- The tool keeps ids and creation instants, sets `updated_at` equal to `created_at`, reads the legacy
  file read-only and refuses a new store that already has an entry.
- The tool copies legacy text unchanged, also when it is empty or whitespace only (TS-TEXT-5).
  The text rule then holds for new writes only, and no history is lost.
- The legacy file stays as a backup. The new system never opens it, except through the tool.

## Consequences

- Good: the new system has one schema and no legacy code path at run time.
- Good: the legacy file is never changed, so the user can return to it.
- Good: the import can be tested on a copy.
- Bad: the user runs one extra step once.
- Bad: the schema in `schema.sql` from the first slice has no `updated_at`.
  Phase 5 adds it. Phase 6 changes the first implementation to match (a store made by the slice is not kept).
- Follow-up: remove the import tool when the user no longer needs it. This needs a new ADR.
