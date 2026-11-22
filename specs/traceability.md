# Traceability

Requirement to scenario to design element to test. One test column per implementation, named by the ADR that adds it.
Spec version of this file: 1.1.1 (ADR-0010). No implementation exists. An implementation adds its own test column when its ADR is accepted.

Test column key: `bdd` = scenario in `features/` run by the BDD runner. `contract` = OpenAPI contract test. `manual` = `@manual` scenario checked in a browser by a person. `frontend` = `@frontend` scenario run by a frontend runner (ADR-0008).

| Requirement | Scenarios | Design element |
|-------------|-----------|----------------|
| REQ-SUB-001 | A valid text becomes an entry with the current time | functional-spec UC-SUB, BR-SUB-3, TS-TIME-1..4, lld submit rule, openapi `POST /`, schema `entries` ; ui-ux submit page |
| REQ-SUB-002 | A whitespace-only text is rejected (outline)<br>form-script.feature: A rejected send keeps the text and moves the focus to it (outline) | BR-SUB-1, TS-TEXT-3, lld `isWhitespaceOnly`, openapi 422 ; ui-ux submit page |
| REQ-SUB-003 | A saved entry clears the form and confirms<br>form-script.feature: A saved send shows the outcome on the same page (outline) | ui-ux messages, lld HTTP outcomes, openapi 303 and `saved` ; ui-ux submit page |
| REQ-SUB-004 | A second send is blocked while the first is in progress (`@manual`)<br>form-script.feature: The form shows that a send is in progress (outline) | ui-ux form state machine ; ui-ux submit page |
| REQ-SUB-005 | The text is stored exactly as entered (outline) | BR-SUB-2, TS-TEXT-1, TS-TEXT-2 ; ui-ux submit page |
| REQ-SUB-006 | A store failure keeps the text<br>form-script.feature: A store failure keeps the text and moves the focus to it (outline)<br>form-script.feature: A lost connection keeps the text and moves the focus to it (outline)<br>form-script.feature: The user can send again after a failure (outline) | functional-spec alternative 5a, lld HTTP outcomes, openapi 503 ; ui-ux submit page |
| REQ-BRW-001 | browse.feature: Entries are listed newest first<br>browse.feature: Entries with the same instant are ordered by id, highest first | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-002 | browse.feature: The viewer uses the default limit and offset | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-003 | browse.feature: The creation instant is shown in the display zone (outline)<br>browse.feature: Line breaks and spaces of the text are kept<br>browse.feature: Each entry links to its update page<br>accessibility.feature: The entry table has column headers<br>accessibility.feature: Entry text keeps its line breaks and spaces and wraps | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-004 | browse.feature: A limit or offset out of range is clamped before entries are read (outline)<br>browse.feature: The offset of an empty diary is 0 | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-005 | browse.feature: The total is shown on every page | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-006 | browse.feature: The next page link shows only while more entries follow (outline) | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-007 | browse.feature: The latest and previous links show only away from offset 0 (outline) | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-008 | browse.feature: The user sets limit and offset in the viewer controls | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-BRW-009 | browse.feature: An empty diary shows a message and no paging links | functional-spec UC-BRW; technical-spec TS-PAGE-1..7; lld 1.2 `page`, 2.2, 2.3, 3; ui-ux viewer and paging machine; openapi `GET /viewer` |
| REQ-UPD-001 | update.feature: The update page holds the current text | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-UPD-002 | update.feature: A valid text replaces the old text<br>update.feature: An update does not change other entries<br>form-script.feature: A saved send shows the outcome on the same page (outline) | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-UPD-003 | update.feature: The update page of a missing entry is not found<br>update.feature: An update of a missing entry is not found and changes nothing | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-UPD-004 | update.feature: A whitespace-only text is rejected and the stored text stays (outline)<br>form-script.feature: A rejected send keeps the text and moves the focus to it (outline) | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-UPD-005 | update.feature: The updated text is stored exactly as entered (outline) | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-UPD-006 | update.feature: A second send is blocked while the first is in progress `@manual`<br>form-script.feature: The form shows that a send is in progress (outline) | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-UPD-007 | update.feature: A store failure keeps the text and shows no success<br>form-script.feature: A store failure keeps the text and moves the focus to it (outline)<br>form-script.feature: A lost connection keeps the text and moves the focus to it (outline)<br>form-script.feature: The user can send again after a failure (outline) | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-UPD-008 | update.feature: An update keeps the id and the creation instant | functional-spec UC-UPD; state-machines entry lifecycle; domain INV-1..5; lld 1.2 `saveText`, 1.3, 3, 4.2; ui-ux update page; openapi `/update/{id}`; schema `updated_at` |
| REQ-EXP-001 | export.feature: The export page offers the choices | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-002 | export.feature: An export starts at the beginning of the date in the display zone | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-003 | export.feature: The export is oldest first when no order is given<br>export.feature: The export is newest first when the user chooses descending | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-004 | export.feature: A Markdown export has a header, a separator and one row per entry | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-005 | export.feature: A tab-separated export has a header and one row per entry | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-006 | export.feature: A Markdown export escapes special characters (outline) | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-007 | export.feature: A tab-separated export escapes special characters and does not quote (outline) | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-008 | export.feature: The creation instant is written in the display zone with its offset (outline) | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-009 | export.feature: A missing or invalid date or format delivers no file (outline) | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-EXP-010 | export.feature: An export with no matching entry has only the header rows | functional-spec UC-EXP; technical-spec escape table, ABNF, TS-DATE-1..4, TS-EXP-1..4; lld 1.4, 2.3 to 2.7, 4.3; ui-ux export page; openapi `GET /export` |
| REQ-IMP-001 | import.feature: Every legacy entry is copied with its id, text and creation instant<br>import.feature: The update instant equals the creation instant<br>import.feature: A legacy entry with whitespace-only text is copied unchanged | functional-spec UC-IMP; state-machines legacy import; technical-spec legacy store format; lld 1.6, 4.4; data/legacy-import.md; ui-ux import tool; ADR-0007 |
| REQ-IMP-002 | import.feature: A second import is refused<br>import.feature: A store that already holds an entry refuses the import | functional-spec UC-IMP; state-machines legacy import; technical-spec legacy store format; lld 1.6, 4.4; data/legacy-import.md; ui-ux import tool; ADR-0007 |
| REQ-IMP-003 | import.feature: A missing legacy file fails with a reason<br>import.feature: A legacy file with no entry table fails with a reason | functional-spec UC-IMP; state-machines legacy import; technical-spec legacy store format; lld 1.6, 4.4; data/legacy-import.md; ui-ux import tool; ADR-0007 |
| REQ-IMP-004 | import.feature: Every legacy entry is copied with its id, text and creation instant | functional-spec UC-IMP; state-machines legacy import; technical-spec legacy store format; lld 1.6, 4.4; data/legacy-import.md; ui-ux import tool; ADR-0007 |
| REQ-IMP-005 | import.feature: One bad legacy entry undoes the whole import | functional-spec UC-IMP; state-machines legacy import; technical-spec legacy store format; lld 1.6, 4.4; data/legacy-import.md; ui-ux import tool; ADR-0007 |
| REQ-IMP-006 | import.feature: A legacy creation instant with no zone marker is read as UTC | functional-spec UC-IMP; state-machines legacy import; technical-spec legacy store format; lld 1.6, 4.4; data/legacy-import.md; ui-ux import tool; ADR-0007 |
| REQ-IMP-007 | import.feature: The legacy file is not changed | functional-spec UC-IMP; state-machines legacy import; technical-spec legacy store format; lld 1.6, 4.4; data/legacy-import.md; ui-ux import tool; ADR-0007 |
| REQ-NFR-001 | browse.feature: Instants are stored in UTC whatever the display zone | technical-spec configuration, TS-TIME, TS-TEXT, TS-NFR; arc42 section 10; domain INV-6, INV-9; lld 1.1 |
| REQ-NFR-002 | browse.feature: The creation instant is shown in the display zone (outline)<br>browse.feature: A configured display zone replaces the default | technical-spec configuration, TS-TIME, TS-TEXT, TS-NFR; arc42 section 10; domain INV-6, INV-9; lld 1.1 |
| REQ-NFR-003 | browse.feature: Entry text is shown as plain text<br>accessibility.feature: Entry text keeps its line breaks and spaces and wraps | technical-spec configuration, TS-TIME, TS-TEXT, TS-NFR; arc42 section 10; domain INV-6, INV-9; lld 1.1 |
| REQ-NFR-004 | browse.feature: The system reads the store location from configuration | technical-spec configuration, TS-TIME, TS-TEXT, TS-NFR; arc42 section 10; domain INV-6, INV-9; lld 1.1 |
| REQ-NFR-005 | update.feature: A store failure keeps the text and shows no success<br>form-script.feature: A store failure keeps the text and moves the focus to it (outline) | technical-spec configuration, TS-TIME, TS-TEXT, TS-NFR; arc42 section 10; domain INV-6, INV-9; lld 1.1 |
| REQ-NFR-006 | browse.feature: A page of a large diary arrives quickly `@manual` | technical-spec configuration, TS-TIME, TS-TEXT, TS-NFR; arc42 section 10; domain INV-6, INV-9; lld 1.1 |
| REQ-NFR-007 | accessibility.feature: Every page state meets the page-wide rules (outline)<br>accessibility.feature: Every form control has a visible linked label (outline)<br>accessibility.feature: Messages are announced (outline)<br>accessibility.feature: After an error the focus is on the control to fix (outline)<br>accessibility.feature: Every task works with the keyboard only<br>accessibility.feature: Every task works with no optional behaviour<br>accessibility.feature: The entry table has column headers<br>accessibility.feature: Entry text keeps its line breaks and spaces and wraps | ui-ux accessibility rules 1 to 8, marker index ; technical-spec TS-RUN, step conventions 16 to 24 |
| REQ-NFR-008 | store.feature: A new store records the schema version<br>store.feature: The schema version stays when the system starts again on the same store | ADR-0009; technical-spec TS-STORE-1..5, step conventions 25 to 28; schema `schema_version`; lld 1.7; arc42 sections 7 and 11; operator guide sections 4 and 5 |
| REQ-NFR-009 | store.feature: A store with a newer schema version is refused and not changed | ADR-0009; technical-spec TS-STORE-1..5, step conventions 25 to 28; schema `schema_version`; lld 1.7; arc42 sections 7 and 11; operator guide sections 4 and 5 |
| REQ-NFR-010 | store.feature: A store with an older schema version is migrated<br>store.feature: A failed migration leaves the store unchanged | ADR-0009; technical-spec TS-STORE-1..5, step conventions 25 to 28; schema `schema_version`; lld 1.7; arc42 sections 7 and 11; operator guide sections 4 and 5 |

## Verification status

| Check | Status |
|-------|--------|
| Each requirement has a feature tag and a row here | Done (grep) |
| `specs/` names no language, framework or library (except ADR-0006) | Done (grep) |
| Mermaid diagrams render | Done (browser preview, 13 diagrams) |
| All scenarios pass in an implementation | Not done. No implementation exists. |
| Contract test against `api/openapi.yaml` | Not done. No implementation exists. |
| OpenAPI lint with a dedicated linter | Done in CI: `spec-checks` run 1 on commit `58c73b3`, 0 errors and 4 warnings (R-8 closed). |
| Import on a copy of real data | Not done. No implementation exists. |
| `@frontend` scenarios checked (ADR-0008) | Not done. No implementation exists. |
| Runners read pages by markers (TS-RUN) | Not done. No implementation exists. |
| Spec checks workflow (`.github/workflows/spec-checks.yml`) | Done: all 6 jobs green in CI, run 1 on commit `58c73b3`. |
| Scenarios of `store.feature` (REQ-NFR-008 to REQ-NFR-010) | Not done. No implementation exists. |
| Browser check against the legacy app | Not done. No implementation exists. The intended differences are below. |

Intended differences from legacy (spec rules):

1. Tab-separated export: legacy ends lines with CRLF and quotes a field that holds a double quote. The new export ends lines with LF (TS-EXP-1) and quotes nothing (REQ-EXP-007).
2. Escaping of backslash and (Markdown only) the pipe character (REQ-EXP-006, REQ-EXP-007).
3. Legacy rejects only the exactly empty text. It stores whitespace-only text (REQ-SUB-002, REQ-UPD-004).
