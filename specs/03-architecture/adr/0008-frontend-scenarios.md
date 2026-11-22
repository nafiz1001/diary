# ADR-0008: Frontend checks as manual Gherkin scenarios

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The scenarios in `features/` run at the domain level. They cannot check what the user sees and does in the user interface:
the states of the form script (`04-design/ui-ux.md`, form state machine) and the accessibility rules.
Only two scenarios (REQ-SUB-004, REQ-UPD-006) checked the user interface, by hand.
The spec must stay language-agnostic (ADR-0003). It must not force one kind of user interface or one test runner on an implementation.

## Considered options

1. Gherkin scenarios tagged `@frontend @manual`. By default a person checks them. An implementation may bind the steps and run them.
2. Gherkin scenarios tagged `@browser`, and a mandatory browser runner in every implementation.
3. A Markdown checklist in a separate verification layer.

## Decision outcome

Chosen option: 1.

- Frontend scenarios are in `features/form-script.feature` and `features/accessibility.feature`, and the double send scenarios in `submit.feature` and `update.feature`.
- Each frontend scenario carries `@frontend` and `@manual`. The domain runner skips `@manual`, so a frontend scenario is a no-op for it.
- The step text uses user terms ("the send control", "the entry text control"). It names no page element, route, markup or tool.
  `04-design/ui-ux.md` (marker index) maps the terms to markers for the current user interface.
- An implementation may add a frontend runner that binds the steps and runs the `@frontend` scenarios. The spec does not change.
  `traceability.md` then records `frontend` for that implementation instead of `manual`.
- A runner that reads pages follows TS-RUN in `02-specification/technical-spec.md`, so that it does not depend on the form of the markup.
- This extends ADR-0006. It does not supersede it.

Rejected option 2: it forces a browser runner on every implementation before it is useful.
Rejected option 3: it adds a second format and ID scheme for checks, and a checklist cannot be run by the existing runners.

## Consequences

- Good: one format and one place for all behaviour checks.
- Good: a check starts manual and becomes automated later with no change to the spec.
- Bad: a manual check is slow and a person can miss a step. `traceability.md` records the date and the result of each manual check.
- Follow-up: the implementation of ADR-0006 has no recorded check of the new frontend scenarios and reads pages with text patterns (risk R-9 in arc42).
