# Operator guide

For the person who runs the diary on one machine. The guide is the same for every implementation.
The exact commands are in the README of the implementation (`implementations/<stack>/README.md`).

## 1. Configuration

The system has three keys: `database_location`, `display_zone` and `listen_address`.
Meaning and defaults are in [`technical-spec.md`](../specs/02-specification/technical-spec.md) (section Configuration).
The machine-readable form is [`config.schema.json`](../specs/04-design/config.schema.json).
The implementation README gives the option or variable name of each key.

| Step | Action |
|------|--------|
| 1 | Keep the default of a key unless you have a reason to change it. |
| 2 | If you set `display_zone`, use a name from the IANA time zone database. An unknown name stops the system at start. |
| 3 | If you move `database_location`, use the same value for the application and for the import tool. |

## 2. Start and stop

| Step | Action |
|------|--------|
| 1 | Start the system with the command in the implementation README. |
| 2 | Open `listen_address` in a web browser. |
| 3 | Stop the system with the interrupt signal of your terminal. The system confirms a write only after the store holds it (REQ-NFR-005), so a stop does not lose a confirmed entry. |

If the system does not start, read the message. These start failures exist:

| Message names | Cause | Action |
|---------------|-------|--------|
| `display_zone` | The zone name is unknown. | Correct the name. |
| `schema_too_new` and a version | The store was made by a newer version of the system (REQ-NFR-009). | Start a newer version. Or restore a backup that an older version made. |
| `migration_failed` | The upgrade of the store failed and the store is unchanged (REQ-NFR-010). | Keep the store file. Report the message. Restore the backup if you need to continue. |

## 3. First run and the legacy import

The system creates an empty store at `database_location` when the file does not exist.
To bring entries from the legacy implementation, run the import tool once.
The steps, the output and the exit status are in [`legacy-import.md`](../specs/04-design/data/legacy-import.md).

| Step | Action |
|------|--------|
| 1 | Copy the legacy store file. Give the tool the copy, not the original. The tool does not change the legacy file (REQ-IMP-007), but a copy is cheap. |
| 2 | Stop the system. |
| 3 | Run the import tool with the copy. The new store must have no entry (REQ-IMP-002). |
| 4 | Read the output `imported: <n>`. Compare `n` with the number of rows in the legacy file. |
| 5 | Start the system. Open the viewer. Check the total. |

## 4. Backup and restore

The store is one file at `database_location`. The database engine can write more files next to it.
These files have the same name prefix as the store file. Copy all of them as one set.

Back up:

| Step | Action |
|------|--------|
| 1 | Stop the system. |
| 2 | Copy the store file and each file with the same name prefix to a safe place. |
| 3 | Start the system. |

Restore:

| Step | Action |
|------|--------|
| 1 | Stop the system. |
| 2 | Remove the store file and each file with the same name prefix. |
| 3 | Copy the backup set to `database_location`. |
| 4 | Start the system. Check the total in the viewer. |

Rules:

- Never copy the files while the system runs. A copy can then mix two states.
- A backup holds all your entries as plain data. Give it the same protection as the store file (threat T-04 in [`threat-model.md`](../specs/03-architecture/threat-model.md)).
- A restored store with an older schema version is migrated at the next start (section 5).
- Try a restore on a copy of the backup at least once, before you need it.

## 5. Upgrade

The store records a schema version (REQ-NFR-008, ADR-0009).

| Step | Action |
|------|--------|
| 1 | Back up the store (section 4). |
| 2 | Stop the system. |
| 3 | Install the new version. |
| 4 | Start the system. If the store has an older schema version, the system migrates it in one transaction (REQ-NFR-010). |
| 5 | Open the viewer. Check the total. |

To go back to an older version of the system, restore the backup of step 1.
An older system refuses a store that a newer system migrated (REQ-NFR-009).

## 6. Network exposure

The system has no sign-in (risk R-5 in [`arc42.md`](../specs/03-architecture/arc42.md)).

- Keep the default `listen_address` (`127.0.0.1:8000`). Only programs on the same machine can reach it.
- Do not set a non-local address, unless a network control that you own restricts who can connect.
- Open the diary only in a browser that you trust. A web page from another site can send requests to a local address (threats T-01 and T-02).
- Keep the store file readable only by your own account (threat T-04). The system does not encrypt the file.
