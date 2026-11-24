# Diary

A personal diary for one user: write notes, browse them, correct them and export them.

The project is spec-driven. The specification is language-agnostic. Implementations are generated from it.

| Path | Content |
|------|---------|
| [`GETTING_STARTED.md`](GETTING_STARTED.md) | Where to start, and how to add, change or remove a feature. |
| [`specs/`](specs/README.md) | Requirements (EARS), behaviour (Gherkin, state machines), architecture (domain model, C4, arc42, ADRs), design (UI/UX, LLD, OpenAPI, SQL schema). |
| [`docs/operator-guide.md`](docs/operator-guide.md) | How to configure, start, back up, restore and upgrade the system, and how to run the one-time import. |
| [`CHANGELOG.md`](CHANGELOG.md) | Versions of the spec. |

No implementation exists now. Each implementation goes in `implementations/<stack>/` (ADR-0003).

Start with [`GETTING_STARTED.md`](GETTING_STARTED.md). It gives a reading order and the steps for each kind of change.
[`specs/README.md`](specs/README.md) holds the rules: the layers, the ID scheme and the change workflow.
[`specs/traceability.md`](specs/traceability.md) links each requirement to its scenarios, design and tests.

## Legacy reference

The code before the restart is in the tag `legacy-v0.1.0`. It is not in the working tree.
To run it as a reference, check it out in a separate worktree, outside this folder:

```bash
git worktree add --detach ../diary-legacy legacy-v0.1.0
```

The old files are at the root of that worktree (`main.py`, `models.py`, `templates/`, `pyproject.toml`).
The legacy app keeps its entries in `sqlite.db` in its working directory. Use a copy of that file to test the import.
Remove the worktree with `git worktree remove ../diary-legacy` when you no longer need it.
