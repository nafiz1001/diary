# ADR-0003: Language-agnostic spec, implementations in separate folders

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The spec must outlive any one technology. A spec that names a language or framework
ties the design to it and hides which decisions are essential.

## Considered options

1. Write the spec for one chosen stack.
2. Keep the spec neutral and put each stack in `implementations/<stack>/`.

## Decision outcome

Chosen option: 2.

- No file in `specs/` names a programming language, framework or library.
  Exception: the ADR that adds an implementation may name its stack.
- Each implementation runs the same `specs/features/*.feature` files with its own BDD runner.
  The step text is the contract. Implementations add step bindings, not scenarios.
- Each implementation passes the same OpenAPI contract and the same export grammar.
- The legacy implementation is a reference only. It does not have to pass the new spec.

## Consequences

- Good: a second implementation in another stack tests the spec itself.
- Good: a reader sees which behaviour is required and which is a stack choice.
- Bad: the spec needs neutral wording. A grep check of `specs/` against a word list enforces it.
