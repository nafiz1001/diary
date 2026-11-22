# ADR-0002: Layered spec process (EARS, Gherkin, arc42, C4, Mermaid)

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The project restarts as spec-driven. The spec must be precise, traceable and readable in plain text.
Each layer needs one format, so that a reader knows where to look.

## Considered options

1. One free-form specification document.
2. Layers with standard formats, linked by IDs.
3. A model-based tool chain with generated documents.

## Decision outcome

Chosen option: 2.

| Layer | Format |
|-------|--------|
| Requirements | EARS statements with `REQ-<AREA>-<NNN>` IDs |
| Behaviour | Gherkin `.feature` files tagged with REQ IDs, state machines in Mermaid |
| Architecture | arc42 sections, C4 views in Mermaid, MADR decisions |
| Design | UI/UX Markdown, OpenAPI 3.1, standard SQL DDL |

`specs/traceability.md` links requirement, scenario, design element and test.

## Consequences

- Good: every layer uses a neutral, plain-text format that diffs well.
- Good: grep can check that each requirement has a scenario and a trace row.
- Bad: the author must keep IDs and links in sync by hand. The verification step checks them.
