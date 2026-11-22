# Traceability

Requirement to scenario to design element to test. One test column per implementation, named by the ADR that adds it.
Rows for the other areas arrive in phases 2 to 6.

Test column key: `bdd` = scenario in `features/` run by the BDD runner. `contract` = OpenAPI contract test. `manual` = checked in a browser.

| Requirement | Scenario (`features/submit.feature`) | Design element | Implementation of ADR-0006 |
|-------------|--------------------------------------|----------------|-------------|
| REQ-SUB-001 | A valid text becomes an entry with the current time | functional-spec UC-SUB, BR-SUB-3, TS-TIME-1..4, lld submit rule, openapi `POST /`, schema `entries` | bdd, contract |
| REQ-SUB-002 | A whitespace-only text is rejected (outline) | BR-SUB-1, TS-TEXT-3, lld `isWhitespaceOnly`, openapi 422 | bdd, contract |
| REQ-SUB-003 | A saved entry clears the form and confirms | ui-ux messages, lld HTTP outcomes, openapi 303 and `saved` | bdd, contract |
| REQ-SUB-004 | A second send is blocked while the first is in progress (`@manual`) | ui-ux form state machine | manual |
| REQ-SUB-005 | The text is stored exactly as entered (outline) | BR-SUB-2, TS-TEXT-1, TS-TEXT-2 | bdd |
| REQ-SUB-006 | A store failure keeps the text | functional-spec alternative 5a, lld HTTP outcomes, openapi 503 | bdd, contract |
| REQ-BRW-001 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-002 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-003 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-004 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-005 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-006 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-007 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-008 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-BRW-009 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-001 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-002 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-003 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-004 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-005 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-006 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-007 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-UPD-008 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-001 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-002 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-003 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-004 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-005 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-006 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-007 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-008 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-009 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-EXP-010 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-IMP-001 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-IMP-002 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-IMP-003 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-IMP-004 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-IMP-005 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-IMP-006 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-IMP-007 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-NFR-001 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-NFR-002 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-NFR-003 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-NFR-004 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-NFR-005 | (phase 3) | (phases 4 and 5) | (phase 6) |
| REQ-NFR-006 | (phase 3) | (phases 4 and 5) | (phase 6) |
