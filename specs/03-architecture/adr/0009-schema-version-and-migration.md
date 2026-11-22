# ADR-0009: Schema version and migration

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The schema will change (ADR-0007 already changed it once). The system has no rule for a store that
was made by another version of the system. An older system can read a newer store and write wrong data.
A newer system can read an older store and fail late. The operator also has no stated way to back up the store.

## Considered options

1. No rule. The operator deletes the store and imports again after each change.
2. A version record in the store. The system migrates an older store forward at start and refuses a newer store.
3. Migrate lazily, table by table, while the system runs.

## Decision outcome

Chosen option: 2.

- The store holds a table `schema_version` with one row. The row holds the integer schema version
  (`../../04-design/data/schema.sql`). The version of this schema is 1 (TS-STORE-1).
- At start the system compares the version of the store with the version that it knows:

| Store version | Result |
|---------------|--------|
| The store has no `entries` table | The system creates the schema at the known version. |
| Equal to the known version | The system starts. |
| Newer than the known version | The system does not start. It names the version (`schema_too_new`). It changes nothing. |
| Older than the known version | The system applies each migration step in order, in one transaction. If a step fails, the system undoes all steps, does not start and reports `migration_failed`. |

- Each migration step goes from version n to version n + 1 and updates the version row in the same transaction.
- The Import tool uses the same check when it opens the new store.
- A backup is a copy of the store file, and of the files with the same name prefix, while the system is stopped.
  The system has no backup command. The operator guide gives the steps (`../../../docs/operator-guide.md`).
- Requirements: REQ-NFR-008, REQ-NFR-009, REQ-NFR-010. Scenarios: `../../features/store.feature`.

Rejected option 1: it loses history on each change.
Rejected option 3: it leaves a store in a mixed state while the system runs, and one version row can no longer describe it.

## Consequences

- Good: a store never meets code that does not know its schema.
- Good: an upgrade is one transaction. A failure leaves the old store usable by the old system.
- Good: a backup needs no tool and no new code path.
- Bad: no downgrade. The operator restores a backup to go back (operator guide, section 5).
- Bad: a store from the first slice has an `entries` table and no version row. The system does not support it,
  because ADR-0007 states that the store of the first slice is not kept. The behaviour for such a store is not defined.
- Bad: the implementation of ADR-0006 does not implement these requirements yet (risk R-10 in arc42).
- Follow-up: a copy of the store while the system runs is not safe. A backup command or an online backup is a possible later change.
