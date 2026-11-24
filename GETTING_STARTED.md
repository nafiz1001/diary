# Getting started

This guide tells you where to start and which files to change when you add, change or remove a feature.
It does not repeat the rules. The rules are in [`specs/README.md`](specs/README.md). This guide links to them.

## 1. What this repo is

- The repo holds a specification of a personal diary. It holds no code.
- The spec names no programming language, framework or library ([ADR-0003](specs/03-architecture/adr/0003-language-agnostic-spec.md)).
- Code goes in `implementations/<stack>/` later. No implementation exists now.

## 2. Read in this order

Read these five files first (about 30 minutes). Skip the other files until a change needs them.

1. [`specs/01-requirements/vision.md`](specs/01-requirements/vision.md): what the diary is for and what is out of scope.
2. [`specs/01-requirements/requirements.md`](specs/01-requirements/requirements.md): every requirement, one row each, with an ID.
3. [`specs/features/submit.feature`](specs/features/submit.feature): how a requirement becomes a test scenario.
4. [`specs/glossary.md`](specs/glossary.md): one term per meaning.
5. [`specs/traceability.md`](specs/traceability.md): for each requirement, its scenarios and design elements.

## 3. How the files link

Every feature follows one chain. The ID connects the links.

```text
REQ-XXX-NNN in requirements.md
  -> @REQ-XXX-NNN tag on scenarios in specs/features/*.feature
  -> design elements that name the ID (functional spec, technical spec, LLD, OpenAPI, schema, UI/UX)
  -> one row in traceability.md
  -> new spec version in specs/README.md and traceability.md, entry in CHANGELOG.md
```

CI checks the first, second and fourth link: each requirement has a tag and a row, and each tag and row has a requirement
(job `traceability` in [`.github/workflows/spec-checks.yml`](.github/workflows/spec-checks.yml)).
CI does not check the design elements or the version. You check them.

## 4. Which file do I touch?

Find each kind of change in your feature. Edit every file in its row.

| Kind of change | Files |
|----------------|-------|
| Any new or changed behaviour | [`requirements.md`](specs/01-requirements/requirements.md), a `.feature` file, [`traceability.md`](specs/traceability.md), [`CHANGELOG.md`](CHANGELOG.md), version line in [`specs/README.md`](specs/README.md) |
| A rule of a use case (main flow, business rule, error case) | [`functional-spec.md`](specs/02-specification/functional-spec.md) (section `UC-<AREA>`) |
| A new scenario step text | [`technical-spec.md`](specs/02-specification/technical-spec.md), section "Scenario step conventions" (add the next number) |
| A new state or transition | [`state-machines.md`](specs/02-specification/state-machines.md), or the form or paging machine in [`ui-ux.md`](specs/04-design/ui-ux.md) |
| A new or changed page, message or form control | [`ui-ux.md`](specs/04-design/ui-ux.md) (page section, "Messages", "Marker index"), [`ui-sketch.md`](specs/02-specification/ui-sketch.md), [`accessibility.feature`](specs/features/accessibility.feature) if the page has new controls |
| A new or changed route or response | [`openapi.yaml`](specs/04-design/api/openapi.yaml), [`lld.md`](specs/04-design/lld.md) sections 1.5, 3 and 4 |
| New logic (contract, algorithm, sequence) | [`lld.md`](specs/04-design/lld.md) sections 1, 2 and 4, and section 5 "Requirements covered" |
| A new stored field or table | [`schema.sql`](specs/04-design/data/schema.sql), [`domain-model.md`](specs/03-architecture/domain-model.md). If existing stores need a migration: schema version rules TS-STORE in [`technical-spec.md`](specs/02-specification/technical-spec.md) ([ADR-0009](specs/03-architecture/adr/0009-schema-version-and-migration.md)), [`operator-guide.md`](docs/operator-guide.md) section 5 |
| A new configuration key | [`config.schema.json`](specs/04-design/config.schema.json), [`technical-spec.md`](specs/02-specification/technical-spec.md) section "Configuration", [`operator-guide.md`](docs/operator-guide.md) section 1, job `config-schema` in the CI workflow (it lists the keys) |
| A new term | [`glossary.md`](specs/glossary.md). Add the term before other files use it. |
| A new risk or attack surface | [`threat-model.md`](specs/03-architecture/threat-model.md), [`arc42.md`](specs/03-architecture/arc42.md) section 11 |
| A new decision (a choice between options) | New ADR in [`specs/03-architecture/adr/`](specs/03-architecture/adr/), row in [`arc42.md`](specs/03-architecture/arc42.md) section 9 |
| A wording fix only | The file, `CHANGELOG.md`, patch version |

## 5. Add a feature

1. Pick the area: `SUB`, `BRW`, `UPD`, `EXP`, `IMP` or `NFR`. Take the next free number in that area of `requirements.md`. Never reuse an ID, also not the ID of a withdrawn requirement.
2. Add the row to `requirements.md`. Use one EARS pattern from the table in [`specs/README.md`](specs/README.md#ears-patterns). Make it testable.
3. Add one or more scenarios to a `.feature` file. Tag each one with `@REQ-<AREA>-<NNN>`.
   - If a step text is new, define it in the step conventions of `technical-spec.md`.
   - If a person checks the scenario in a browser, also tag it `@manual`. If it checks the user interface, tag it `@frontend @manual` ([ADR-0008](specs/03-architecture/adr/0008-frontend-scenarios.md)).
4. Update the design files that the table in section 4 names. In each design element, name the requirement ID.
5. If the feature needs a decision, add an ADR (section 8).
6. Add the row to `traceability.md`: requirement, scenario names, design elements.
7. Set the version: a new requirement or scenario is a minor bump (1.1.1 to 1.2.0). Change it in two places:
   line 3 of `specs/README.md` and line 4 of `traceability.md`.
8. Add an entry to `CHANGELOG.md` under `### Added`, with the date.
9. Run the checks (section 9).

## 6. Change a feature

1. Find the requirement ID. Open its row in `traceability.md`. The row lists each file to look at.
2. Change the requirement row, then the scenarios, then the design elements.
3. Set the version with the rules in [`specs/README.md`](specs/README.md#version):
   - Wording only: patch.
   - A scenario changes, or the contract changes (OpenAPI, export grammar, a schema change that needs a data migration): major.
   - If you are not sure, use the test of [ADR-0010](specs/03-architecture/adr/0010-spec-versioning.md): can an implementation that passed the old version now fail? If yes, it is major.
4. If the schema changes and existing stores need a migration, raise the schema version (TS-STORE in `technical-spec.md`, ADR-0009).
5. If the change reverses an accepted ADR, do not edit that ADR. Add a new ADR that supersedes it (section 8).
6. Add the `CHANGELOG.md` entry under `### Changed`.

## 7. Remove a feature

1. Keep the row in `requirements.md`. Write `Withdrawn` in it and say why. Do not delete the row. The ID stays used.
2. Remove the `@REQ-...` tag from each scenario. If a scenario checks nothing else, delete the scenario.
3. Delete the row in `traceability.md`. CI fails if a row stays for a withdrawn requirement.
4. Remove the design elements that only this requirement uses. Remove the ID from the others.
5. Set the version: a removed scenario is a major bump (1.1.1 to 2.0.0).
6. Add the `CHANGELOG.md` entry under `### Removed`.

## 8. Add a decision (ADR)

1. Take the next number. The last one is in [`arc42.md`](specs/03-architecture/arc42.md) section 9.
2. Copy the shape of [ADR-0009](specs/03-architecture/adr/0009-schema-version-and-migration.md): status, date, context, considered options, decision outcome, consequences.
3. Name the file `NNNN-short-title.md`.
4. Add the row to the table in `arc42.md` section 9.
5. To replace an older ADR, set its status line to `superseded by ADR-NNNN`. Change nothing else in it.

## 9. Run the checks before you push

CI runs six jobs on each push and pull request. Two of them need only the shell. Run them from the repo root.

Requirement IDs, tags and traceability rows match:

```bash
t=$(mktemp -d); grep -v Withdrawn specs/01-requirements/requirements.md | grep -oE '^\| REQ-[A-Z]+-[0-9]{3}' | sed 's/^| //' | sort -u > "$t/req"; grep -ohE '@REQ-[A-Z]+-[0-9]{3}' specs/features/*.feature | sed 's/^@//' | sort -u > "$t/tags"; grep -oE '^\| REQ-[A-Z]+-[0-9]{3}' specs/traceability.md | sed 's/^| //' | sort -u > "$t/trace"; echo "no tag:"; comm -23 "$t/req" "$t/tags"; echo "tag, no requirement:"; comm -13 "$t/req" "$t/tags"; echo "no row:"; comm -23 "$t/req" "$t/trace"; echo "row, no requirement:"; comm -13 "$t/req" "$t/trace"; rm -r "$t"
```

The four lists must be empty.

No language or library name in `specs/`: run the three `grep` lines of job `no-language-names` in the
[workflow](.github/workflows/spec-checks.yml). They must print nothing.

The other jobs need Node (`npx`). Copy their commands from the same workflow if you want to run them locally:
`openapi-lint` (after a change to `openapi.yaml`), `gherkin-lint` (after a change to a `.feature` file),
`mermaid-render` (after a change to a diagram) and `config-schema` (after a change to `config.schema.json`).

## 10. Worked example: delete an entry

This example is not part of the spec. It shows the size of one small feature. `REQ-UPD-009` is free now.

`requirements.md`, section Update:

```markdown
| REQ-UPD-009 | Event-driven | When the user confirms the deletion of an existing entry, the system shall remove the entry and tell the user that the entry was deleted. |
```

`update.feature`:

```gherkin
  @REQ-UPD-009
  Scenario: A confirmed deletion removes the entry
    Given the diary has 3 numbered entries
    When the user deletes entry 2 and confirms
    Then the diary has 2 entries
    And the user is told "Entry deleted."
```

`technical-spec.md`, step conventions: add number 29 for the new step `the user deletes entry N and confirms`.

Design files:

- `functional-spec.md`: add a flow and an error case to `UC-UPD` (or a new `UC-DEL`).
- `ui-ux.md`: a delete control and a confirmation on the update page, the new message, new markers in the marker index.
- `openapi.yaml`: a new route for the deletion, with its responses (303, 404, 503).
- `lld.md`: a `delete` contract in 1.2, the sequence in section 4, the ID in section 5.
- `state-machines.md`: a `Deleted` end state in the entry lifecycle.
- `domain-model.md`: check that no invariant says an entry lives forever.

`traceability.md`:

```markdown
| REQ-UPD-009 | update.feature: A confirmed deletion removes the entry | functional-spec UC-UPD; state-machines entry lifecycle; lld 1.2 `delete`, 4.5; ui-ux update page; openapi delete route |
```

Version: 1.1.1 to 1.2.0 in `specs/README.md` and `traceability.md`. Changelog entry under `### Added`.

## 11. Mistakes to avoid

- A language, framework or library name anywhere in `specs/`. CI fails.
- An edit to an accepted ADR. Supersede it.
- A reused ID, or a deleted requirement row. Mark it `Withdrawn`.
- A requirement with no `@REQ-...` tag, or a tag with no requirement. CI fails.
- A version bump in only one of `specs/README.md` and `traceability.md`. CI does not catch it.
- Code that needs behaviour the spec does not define. Stop and change the spec first.
