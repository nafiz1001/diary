# Test strategy

How the spec is verified. This file links to the sources. It does not repeat them.

## 1. Scope

| In scope | Out of scope |
|----------|--------------|
| Behaviour in `features/*.feature` (every `REQ-` ID) | Performance beyond REQ-NFR-006 |
| The HTTP contract in `04-design/api/openapi.yaml` | Penetration tests (see `03-architecture/threat-model.md`) |
| The export grammar (`02-specification/technical-spec.md`) | Browsers other than the one that the person who checks uses |
| The user interface rules in `04-design/ui-ux.md` | Load with more than one user (one user only) |
| The import tool and the store start-up check | Tests of the legacy implementation |

## 2. Test levels

| Level | Tag or name | What it checks | Run by | Source |
|-------|-------------|----------------|--------|--------|
| BDD | none | Domain behaviour of each requirement | Domain runner of the implementation | `features/*.feature`, step conventions 1 to 28 |
| Contract | `contract` | Live responses match the OpenAPI file | Contract test of the implementation | `04-design/api/openapi.yaml` |
| Manual | `@manual` | Behaviour that a domain runner cannot check (double send, large diary) | A person | `traceability.md` records each check |
| Frontend | `@frontend @manual` | The user interface, form states and accessibility (ADR-0008) | A person, or a frontend runner | `features/form-script.feature`, `features/accessibility.feature`, `04-design/ui-ux.md` |
| Spec checks | none | The spec files themselves: lint, diagrams, tags, names, schema | The workflow `.github/workflows/spec-checks.yml` | `specs/README.md` (Definition of Done) |

The test column of `traceability.md` uses the names in the second column (`bdd`, `contract`, `manual`, `frontend`).

## 3. Runners

| ID | Rule | Source |
|----|------|--------|
| TS-RUN-1 to TS-RUN-4 | A runner reads pages with a document parser and finds elements by markers. | `02-specification/technical-spec.md` |
| Skip rule | A domain runner skips `@manual`. | `README.md`, rule 4 |
| Binding rule | An implementation adds step bindings, not scenarios. | `README.md`, rule 3 |

The runner and the test command of an implementation are in the README of that implementation
and in the ADR that adds it.

## 4. Test data

| Data | Source | Use |
|------|--------|-----|
| Numbered entries | Step convention 4 | Paging, order |
| Entry tables | Step conventions 5 and 6 | Time, text, export |
| Legacy store | Step convention 9 for scenarios. For a real check, a copy of a legacy store file that the user gives (risk R-7). | Import |
| Store with a schema version | Step conventions 25 to 28 | Start-up check (`features/store.feature`) |
| Large diary | 100000 entries, made by a script of the implementation | REQ-NFR-006, manual check |
| Whitespace and special characters | Tokens in step convention 2 | Text and export |

Never put real diary entries in the repository. Use a copy outside the repository for a check on real data.

## 5. Environments

| Environment | Use |
|-------------|-----|
| Developer machine | All levels. One personal machine, as in arc42 section 7. |
| CI | Spec checks only (`.github/workflows/spec-checks.yml`). No implementation runs there yet. |
| Real data copy | One import check on a copy of the real legacy store (not done yet, see `traceability.md`). |

## 6. Entry and exit criteria (Definition of Done)

Entry to a test run:

1. The change follows the workflow in `README.md`: requirement, scenarios and design, ADR, then implementation.
2. The spec checks pass.

Exit, that is, done: the Definition of Done per layer in `README.md`. In short:

| Layer | Criterion |
|-------|-----------|
| Requirements | Each requirement has an ID, an EARS pattern, and is testable. |
| Specification | Each requirement has a tagged scenario. Each state machine has a transition table. |
| Architecture | Each significant decision has an ADR. Each diagram renders. |
| Design | The OpenAPI file lints. The DDL is standard SQL. Each contract names its requirements. |
| Implementation | All scenarios and the contract test pass. Each `@manual` scenario has a recorded check. The test column of `traceability.md` is filled. The spec version that passed is recorded. |

## 7. Evidence

| Evidence | Where |
|----------|-------|
| Requirement to scenario to design to test | `traceability.md` |
| State of each check | `traceability.md`, section Verification status |
| Spec version that an implementation passes | `traceability.md`, header (ADR-0010) |
| Result of the spec checks | The run of the workflow in CI |

A manual check records the date, the person or the runner, and the result.

## 8. Open items

| Item | Status | Source |
|------|--------|--------|
| R-8 OpenAPI lint | Closed. The workflow lints the file and the first run was green. | `03-architecture/arc42.md` |
| R-9 Page reading by text patterns, `@frontend` scenarios not checked | Closed (implementation removed) | `03-architecture/arc42.md` |
| R-10 REQ-NFR-008 to REQ-NFR-010 not implemented | Closed (implementation removed) | `03-architecture/arc42.md` |
| Import on a copy of the real legacy store | Open (R-7) | `traceability.md` |
