# ADR-0001: Record architecture decisions

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The legacy diary grew with no written record of why it works the way it does.
A later reader (a person or an AI agent) cannot recover the reasons for a choice.

## Considered options

1. Record decisions in commit messages only.
2. Record decisions in one design document.
3. Record each decision in its own short file (MADR format).

## Decision outcome

Chosen option: 3. Write one MADR file per significant decision in `specs/03-architecture/adr/`.
Number files `NNNN-title.md`. Do not edit an accepted ADR. Add a new ADR that supersedes it.

## Consequences

- Good: each decision has a stable ID and a history.
- Good: a new reader finds the reasons next to the architecture.
- Bad: each decision costs a small writing effort.
