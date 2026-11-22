# Diary specification

This folder holds the layered, language-agnostic specification of the diary.
Each implementation in `implementations/<stack>/` is generated from it.

## Layers

| Layer | Folder | Content | Format |
|-------|--------|---------|--------|
| 1 Requirements | `01-requirements/` | Vision, scope, requirements | Markdown, EARS |
| 2 Specification | `02-specification/`, `features/` | Use cases, rules, state machines, scenarios | Markdown, Gherkin, Mermaid |
| 3 Architecture (HLD) | `03-architecture/` | Domain model, C4, arc42, ADRs | Markdown, Mermaid, MADR |
| 4 Design (UI/UX, LLD) | `04-design/` | Wireframes, contracts, API, schema | Markdown, OpenAPI 3.1, standard SQL |

Shared files: `glossary.md` (one term per meaning) and `traceability.md`
(requirement to scenario to design element to test).

## Language-agnostic rules

1. Use only neutral formats: Markdown, EARS text, Gherkin, Mermaid, OpenAPI 3.1 YAML, JSON Schema, standard SQL DDL.
2. Do not name a programming language, framework or library in `specs/`.
   The stack appears only in `implementations/<stack>/` and in the ADR that adds that implementation.
3. Each implementation runs the same `features/*.feature` files with its own BDD runner.
   The step text is the contract. Implementations add step bindings, not scenarios.
4. Each implementation passes the same OpenAPI contract and the same export format grammar.
5. The legacy implementation is a reference only. It does not have to pass this spec.

## ID scheme

- Requirement: `REQ-<AREA>-<NNN>`. AREA is `SUB`, `BRW`, `UPD`, `EXP`, `IMP` or `NFR`.
- Scenario: carries one or more `@REQ-...` tags.
- Decision: `ADR-NNNN` (file `03-architecture/adr/NNNN-title.md`).
- Never reuse an ID. Mark a dropped requirement as `Withdrawn`.

## EARS patterns

| Pattern | Template |
|---------|----------|
| Ubiquitous | The system shall `<response>`. |
| Event-driven | When `<event>`, the system shall `<response>`. |
| State-driven | While `<state>`, the system shall `<response>`. |
| Unwanted behaviour | If `<condition>`, then the system shall `<response>`. |
| Optional feature | Where `<feature>`, the system shall `<response>`. |

## Change workflow

1. Add or change the EARS requirement.
2. Update the scenarios, state machines and design.
3. If a decision changes, add an ADR. Do not edit an accepted ADR. Supersede it.
4. Change each implementation until all scenarios pass.

If code needs behaviour that the spec does not define, stop and update the spec first.

## Definition of Done per layer

- Requirements: every requirement has an ID, uses an EARS pattern, and is testable.
- Specification: every requirement has at least one tagged scenario. Every state machine has a transition table.
- Architecture: every significant decision has an ADR. Every diagram renders.
- Design: the OpenAPI file lints. The DDL is standard SQL. Every contract names its requirements.
- Implementation: all scenarios and the contract test pass. `traceability.md` has the test column filled.
