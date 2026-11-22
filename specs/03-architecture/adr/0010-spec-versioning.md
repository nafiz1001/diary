# ADR-0010: Spec versioning

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

The spec changes (new requirements, new scenarios). An implementation, a reader and the traceability file need to name
the state of the spec that they match. Today the only name is a commit hash.

## Considered options

1. No version. Use commit hashes.
2. Semantic Versioning of the spec as a whole, with a root `CHANGELOG.md`.
3. A version per layer or per file.

## Decision outcome

Chosen option: 2.

| Part | Rule |
|------|------|
| Number | `MAJOR.MINOR.PATCH`, as in Semantic Versioning 2.0.0. |
| Major | A scenario changes or is removed, or the contract changes (OpenAPI, export grammar, schema in a way that needs a migration of existing data). An implementation that passed the old version can fail. |
| Minor | A requirement or a scenario is added. An implementation that passed the old version still passes the old scenarios. |
| Patch | Wording only. No requirement, scenario or contract changes. |
| Where | `README.md` of `specs/` holds the current version. `CHANGELOG.md` at the root lists each version (Keep a Changelog format). |
| Baseline | Version 1.0.0 is the state at commit `5555a3f`. |
| Evidence | `traceability.md` records the spec version that each implementation passes. |
| Release | A version number is set when the change merges. The same change adds the entry in `CHANGELOG.md`. |

The change workflow in `specs/README.md` stays. Step 5 is new: set the version and add the changelog entry.

Rejected option 1: a hash says nothing about the size of a change.
Rejected option 3: it makes the match between an implementation and the spec hard to state.

## Consequences

- Good: an implementation states one number, "passes spec 1.1.0".
- Good: the size of a change shows in the number.
- Bad: each change needs a version decision and a changelog entry.
- Bad: the version is a manual value. The CI workflow does not check it.
