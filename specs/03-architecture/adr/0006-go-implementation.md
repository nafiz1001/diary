# ADR-0006: First spec-generated implementation in Go

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The spec needs a first implementation to prove that it is complete and portable (ADR-0003).
The user chose the stack.

## Considered options

1. Python with a web framework and pytest-bdd (same stack as the legacy implementation).
2. TypeScript on Node with cucumber-js.
3. Go with the standard HTTP library and godog.

## Decision outcome

Chosen option: 3. This ADR is the one place where a stack is named.

| Concern | Choice |
|---------|--------|
| Folder | `implementations/go-net-http/` |
| Language and HTTP | Go, standard library `net/http` and `html/template` |
| Database | A pure-Go driver for a single-file SQL database (no C compiler needed) |
| BDD runner | godog, running `specs/features/*.feature` with `~@manual` |
| Contract test | An OpenAPI 3 validation library that checks live responses against `specs/04-design/api/openapi.yaml` |

The implementation translates the identity column of `schema.sql` to the engine form for its database.
It keeps the table and column names, the column types in meaning, and the constraints.

## Consequences

- Good: a different stack from the legacy code, so the spec is tested for portability.
- Good: one static binary. No interpreter or virtual environment to run.
- Bad: three third-party modules for the database, BDD and contract test. The module file pins them.
