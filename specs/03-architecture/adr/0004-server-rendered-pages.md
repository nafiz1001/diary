# ADR-0004: Server-rendered pages with small progressive enhancement

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The user uses a web browser. The legacy implementation renders pages on the server and adds a small script
that sends forms in the background. The system needs a user interface that stays simple and always works.

## Considered options

1. Server-rendered pages only.
2. Server-rendered pages plus a small optional script that improves forms.
3. A single-page client application that talks to a data API.

## Decision outcome

Chosen option: 2.

- Every page and every form works with no script (TS-NFR-1).
- A small optional script blocks double sends and shows status without a page reload.
- When a request says it accepts JSON, the system answers with JSON for form routes (see `04-design/lld.md`).

## Consequences

- Good: simple to build and port. Works in any browser.
- Good: behaviour is testable at the domain level and at the HTTP level.
- Bad: two response forms per form route (page and JSON). The OpenAPI contract describes both.
