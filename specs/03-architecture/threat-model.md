# Threat model

Method: STRIDE per element of the C4 container view (`c4.md`, level 2).
Scope: one personal machine, one user, no sign-in. The system listens on a local address by default (arc42 section 7).
This file adds no behaviour requirement. A threat with no mitigation is a risk in `arc42.md` section 11.

STRIDE: S spoofing, T tampering, R repudiation, I information disclosure, D denial of service, E elevation of privilege.

## Assets and trust

| Asset | Why it matters |
|-------|----------------|
| Entry text | Private. The user cannot replace a lost or changed entry. |
| Entry store file | Holds all entries as plain data. |
| Backup copies | Hold the same data as the store file. |
| Legacy store file | The only copy of the old history. The import never changes it (REQ-IMP-007). |

| Actor | Trust |
|-------|-------|
| The user | Trusted. Has full access to the machine account. |
| Other accounts on the machine | Not trusted. |
| Web pages from other sites that the user's browser opens | Not trusted. They can make the browser send requests. |
| Other machines on the network | Not trusted. |

## Threats by element

| ID | Element | STRIDE | Threat | Mitigation now | Risk |
|----|---------|--------|--------|----------------|------|
| T-01 | Diary application | S, T | A page from another site makes the browser send `POST /` or `POST /update/{id}`. The system cannot tell it from the user's own form, so it stores or replaces text (cross-site request forgery). | None. The system does not check the origin of a request and has no request token. | R-11 |
| T-02 | Diary application | S, I | A page from another site uses a name that it later points to the local address (DNS rebinding). The browser then lets the page read the viewer and the export. | None. The system does not check the host name of a request. | R-12 |
| T-03 | Diary application, Entry store | T, E | Entry text holds markup or script. A page or an export would run it (script injection). | Mitigated. The system shows text as plain text and never reads it as markup (REQ-NFR-003, TS-TEXT-6). Scenario `Entry text is shown as plain text`. The export escape table covers the export formats (REQ-EXP-006, REQ-EXP-007). | none |
| T-04 | Entry store | I | Another account on the machine reads the store file or a backup. The data is not encrypted at rest. | None in the system. The operator guide tells the operator to restrict the file to the own account. | R-13 |
| T-05 | Import tool, Legacy store file | T, I | A crafted or damaged legacy file makes the import write wrong data or change the legacy file. | Mitigated. The tool opens the legacy file read-only (REQ-IMP-007), checks every row (REQ-IMP-005), and copies in one transaction. Copied text is shown as plain text (T-03). | none |
| T-06 | Diary application | I, T | The operator sets a non-local `listen_address`. Anyone who reaches the address reads and writes the diary. | The default is local. The operator guide, section 6, tells the operator to keep it. No technical control. | R-5 |
| T-07 | Diary application | D | A request with very large text, or a large export, uses all memory or all time. No maximum text length exists (TS-TEXT-4). | Partial. The export writes row by row (R-3). The system takes any text size on submit. | R-14 |
| T-08 | Entry store | D, T | A failed upgrade or a failed write leaves a damaged store. | Mitigated. One transaction per change (INV-8). One transaction for a migration, with no change on failure (REQ-NFR-010). The operator backs up before an upgrade. | none |
| T-09 | Entry store | D | The operator loses the store file. | Partial. The operator guide gives the backup steps (ADR-0009). The system makes no backup by itself. | none (operator duty) |
| T-10 | Diary application | R | The user denies an entry or an update. | Accepted. One user, no sign-in, no audit log. The creation instant and the update instant are the only record. | none |
| T-11 | User (web browser) | S | Another program on the machine pretends to be the user. | Accepted. The machine account is the trust boundary. A program that runs as the user can read the store file directly. | none |

## STRIDE check per element

| Element | S | T | R | I | D | E |
|---------|---|---|---|---|---|---|
| Diary application | T-01, T-02 | T-01, T-03, T-06 | T-10 | T-02, T-06 | T-07 | T-03 |
| Import tool | none (command line, run by the operator) | T-05 | none (operator run) | T-05 | none (one run) | none |
| Entry store | none | T-03, T-08 | none | T-04 | T-08, T-09 | none |
| Legacy store file | none | T-05 | none | T-05 | none | none |
| User (web browser) | T-11 | none | T-10 | none | none | none |

## Follow-up

No new behaviour requirement comes from this task. These are possible later requirements. Each needs the change workflow (`../README.md`).

| Threat | Possible requirement |
|--------|----------------------|
| T-01 | Reject a write request whose origin is not the system's own address. Or add a per-form token. |
| T-02 | Reject a request whose host name is not the listen address or a local name. |
| T-04 | Create the store file with owner-only permissions. |
| T-07 | Set a maximum request size. |
