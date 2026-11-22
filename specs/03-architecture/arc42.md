# Architecture (arc42)

Short, with links to the files that hold the detail.

## 1. Introduction and goals

- Purpose: a personal diary for one user. See `../01-requirements/vision.md`.
- Top quality goals:
  1. Correct text and time handling (no change of text, UTC storage, display zone).
  2. Simplicity (one application, one file of data).
  3. Portability of the spec across stacks.
- Stakeholders: the user (reads, writes, exports) and the developer (extends, ports).

## 2. Constraints

- The spec names no programming language, framework or library (ADR-0003).
- Data lives in one single-file relational database (ADR-0005).
- The user interface is a web browser (ADR-0004).
- The system runs on one personal machine for one user.
- The legacy store is read once and never changed (ADR-0007).

## 3. Context and scope

See `c4.md`, level 1.

| Neighbour | Exchange |
|-----------|----------|
| User | Sends entry text, date, order and format. Receives pages and files. |
| Web browser | Carries HTTP between the user and the system. |
| Legacy store file | Read once by the import tool. |

Out of scope: sign-in, sharing, sync, delete, search (see the vision).

## 4. Solution strategy

| Goal | Approach |
|------|----------|
| Simple | One application, one database file, one import tool. |
| Works without script | Server-rendered pages. Forms post and redirect (ADR-0004). |
| Portable spec | Gherkin scenarios and an OpenAPI contract that each implementation runs (ADR-0003). |
| Correct time | Store UTC. Convert to the display zone only to show a time or to write an export. |
| Correct text | Store text unchanged. Show text as plain text. Escape text in exports. |
| Safe writes | One transaction per change. Confirm after the store holds the data (INV-8, INV-9). |

## 5. Building block view

Level 1 (containers, `c4.md` level 2):

| Block | Responsibility |
|-------|----------------|
| Diary application | Receive requests, check rules, read and write entries, render pages and files. |
| Import tool | Copy the legacy store into the new store once. |
| Entry store | Keep entries durable. Schema in `../04-design/data/schema.sql`. |

Level 2 (components of the Diary application, `c4.md` level 3): page handlers, entry rules,
export writers, time and zone, page renderer, entry repository, configuration.

Domain model, aggregate and invariants: `domain-model.md`.

## 6. Runtime view

Detailed sequence diagrams are in `../04-design/lld.md`. The main scenarios:

| Scenario | Flow |
|----------|------|
| Submit | Page handler, Entry rules (check text, read clock), Entry repository (add), redirect. |
| Browse | Page handler, Entry rules (clamp with total), Entry repository (page), Page renderer (convert instants). |
| Update | Page handler, Entry rules (find, check text, read clock), Entry repository (save), Page renderer. |
| Export | Page handler, Entry rules (check request, start of date), Entry repository (since), Export writer, file. |
| Import | Import tool: check target, check legacy file, one transaction of row copies, commit, report. |

## 7. Deployment view

One personal machine. One process for the Diary application. One file for the Entry store.
The Import tool is a separate short-lived process that runs once.

| Item | Location |
|------|----------|
| Entry store file | `database_location` (default `diary.db` in the working directory) |
| Listen address | `listen_address` (default `127.0.0.1:8000`) |
| Legacy store file | A path that the operator gives to the Import tool |

The system listens on the local address by default because it has no sign-in.

Backup and upgrade (ADR-0009, `../../docs/operator-guide.md`):

| Item | Rule |
|------|------|
| Backup | Stop the system. Copy the Entry store file and each file with the same name prefix (TS-STORE-5). |
| Restore | Stop the system. Replace the files with the backup. Start the system. |
| Upgrade | Back up. Install the new version. Start. The system migrates an older store in one transaction and refuses a newer store (REQ-NFR-009, REQ-NFR-010). |
| Schema version | Recorded in the table `schema_version` of the Entry store (REQ-NFR-008). |

## 8. Crosscutting concepts

| Concept | Rule |
|---------|------|
| Time | UTC in the store. Display zone for show and export (TS-TIME-*, TS-DATE-*). |
| Text | Unchanged in the store. Plain text on pages. Escaped in exports (TS-TEXT-*, escape table). |
| Errors | Each refusal has a reason code (`domain-model.md`). Pages show a message and keep the user's input. |
| Configuration | Three keys (`../02-specification/technical-spec.md`). |
| Security | One local user, no sign-in. Entry text is never read as markup (REQ-NFR-003). The default listen address is local. Threats and gaps: `threat-model.md`. |
| Transactions | One transaction per change. The import is one transaction. |
| Progressive enhancement | Every flow works with no script. The script only blocks double sends and shows status (ADR-0004). |

## 9. Architecture decisions

| ADR | Decision |
|-----|----------|
| 0001 | Record architecture decisions |
| 0002 | Layered spec process |
| 0003 | Language-agnostic spec |
| 0004 | Server-rendered pages with small progressive enhancement |
| 0005 | Single-file relational database with a standard SQL schema |
| 0006 | First spec-generated implementation (stack named in the ADR) |
| 0007 | New schema and one-time legacy import |
| 0008 | Frontend checks as manual Gherkin scenarios |
| 0009 | Schema version recorded in the store, forward migration at start, backup by file copy |
| 0010 | Semantic Versioning of the spec, root changelog |

Version of the spec: see `../README.md` (ADR-0010). Changes: `../../CHANGELOG.md`.

## 10. Quality requirements

Quality tree: correctness, performance, portability, usability, accessibility.

| ID | Quality | Stimulus | Response | Measure | Requirement |
|----|---------|----------|----------|---------|-------------|
| Q-1 | Correctness | The user submits text with leading spaces, tabs and line breaks. | The system stores it unchanged. | Stored text equals the input byte for byte. | REQ-SUB-005, REQ-UPD-005 |
| Q-2 | Correctness | The user views an entry made at 03:00 UTC in winter. | The viewer shows the time in the display zone. | `2026-01-05 (Mon) 22:00:00` for 2026-01-06 03:00 UTC with the default zone. | REQ-BRW-003, REQ-NFR-002 |
| Q-3 | Correctness | An entry holds a pipe, a backslash or a line break and the user exports it. | The export escapes it. A reader can restore the text. | Export grammar matches. No raw line break or tab in a field. | REQ-EXP-006, REQ-EXP-007 |
| Q-4 | Reliability | The store fails during a write. | The system shows a failure, keeps the user's text and stores nothing. | No partial entry. No success message. | REQ-SUB-006, REQ-UPD-007, REQ-NFR-005 |
| Q-5 | Performance | The diary has 100000 entries and the user opens any page. | The system answers. | Under 1 second on a personal machine. | REQ-NFR-006 |
| Q-6 | Security | An entry holds `<script>` text. | The viewer shows it as text. | No markup is read from entry text. | REQ-NFR-003 |
| Q-7 | Data safety | The import fails at the 500th row. | The system rolls back. | The new store has 0 entries. The legacy file is unchanged. | REQ-IMP-005, REQ-IMP-007 |
| Q-8 | Portability | A developer builds a second implementation. | The developer needs no change to the spec. | All scenarios and the contract test pass. | ADR-0003 |
| Q-9 | Usability | The user has no script support in the browser. | Every page and form works. | All scenarios pass with no script. | ADR-0004, TS-NFR-1 |
| Q-10 | Accessibility | The user uses the keyboard only or a screen reader. | Every page and form works. Messages are announced. | All scenarios in `accessibility.feature` pass. | REQ-NFR-007 |

## 11. Risks and technical debt

| ID | Risk or debt | Mitigation |
|----|--------------|------------|
| R-1 | The system clock moves back. An update instant could be before the creation instant. | Not handled in version 1. Add a rule if it happens. |
| R-2 | One writer at a time (single-file database). | Fine for one user. |
| R-3 | A large export reads many entries. | Write the file row by row. Do not hold all rows in memory. Checked in phase 6. |
| R-4 | No delete. A mistaken entry stays. | The user can update the text. A delete is out of scope. |
| R-5 | No sign-in. Anyone who reaches the address can read the diary. | Listen on a local address by default. |
| R-6 | The first slice has a schema with no `updated_at`. | Phase 5 completes the schema. Phase 6 changes the first implementation. |
| R-7 | The legacy store file is not in the repository, so the import test needs a copy from the user. | Ask the user for a copy in phase 6. |
| R-8 | Closed. The OpenAPI file was not checked with a dedicated linter. | The workflow `.github/workflows/spec-checks.yml` lints it. First green run: run 1 on commit `58c73b3` (0 errors, 4 warnings: no `servers`, no `info.contact`, two operations with no description). |
| R-9 | The implementation of ADR-0006 reads pages with text patterns over the markup (breaks TS-RUN). No check of the new `@frontend` scenarios is recorded. | Change its runner to a document parser and check the `@frontend` scenarios in a follow-up task. |
| R-10 | The implementation of ADR-0006 does not implement REQ-NFR-008 to REQ-NFR-010 (schema version, refusal of a newer store, migration). It passes spec version 1.0.0 only. | Implement them in a separate task, with the step bindings of conventions 25 to 28. Until then `traceability.md` shows "not implemented". |
| R-11 | Threat T-01: a page from another site can make the browser send a write request. The system has no origin check and no form token. | Operator guide: open the diary only in a browser that you trust. Follow-up requirement in `threat-model.md`. |
| R-12 | Threat T-02: DNS rebinding can let a page from another site read the diary through the local listener. The system has no host name check. | Same as R-11. |
| R-13 | Threat T-04: the Entry store file and the backups are not encrypted and the system sets no file permissions. | Operator guide: restrict the files to the own account. Follow-up requirement in `threat-model.md`. |
| R-14 | Threat T-07: there is no maximum size of a submitted text (TS-TEXT-4). A very large request can use all memory. | Accepted for one local user. Follow-up requirement in `threat-model.md`. |

## 12. Glossary

See `../glossary.md`.
