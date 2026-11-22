# Changelog

All notable changes to the spec are in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The version follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) as set by ADR-0010.

## [1.1.1] - 2026-11-22

### Removed

- The Go implementation of ADR-0006. ADR-0006 is deprecated.
- The implementation column in `specs/traceability.md`. The checks that need an implementation show "Not done".

### Changed

- Risks R-9 and R-10 in arc42 are closed. The next implementation reads pages by markers (TS-RUN) and implements REQ-NFR-008 to REQ-NFR-010.

## [1.1.0] - 2026-11-22

### Added

- REQ-NFR-008, REQ-NFR-009 and REQ-NFR-010: schema version in the store, refusal of a newer store, forward migration at start.
- `specs/features/store.feature` with five scenarios, and step conventions 25 to 28 in the technical spec.
- ADR-0009 (schema version and migration) and ADR-0010 (spec versioning).
- Table `schema_version` in `specs/04-design/data/schema.sql`. Start-up check in the LLD (section 1.7). Rules TS-STORE-1 to TS-STORE-5.
- Reason codes `schema_too_new` and `migration_failed`.
- Terms Schema version and Backup in the glossary.
- `specs/test-strategy.md`.
- `specs/03-architecture/threat-model.md` (STRIDE) and risks R-10 to R-14 in arc42.
- `specs/04-design/config.schema.json` (JSON Schema for the three configuration keys).
- `docs/operator-guide.md` (configuration, start, import, backup, upgrade, network exposure).
- `.github/workflows/spec-checks.yml` (automated checks of the Definition of Done).
- Spec version and change workflow step 5 in `specs/README.md`. "Spec version passed" line in `specs/traceability.md`.

### Changed

- The README of the repository no longer says that the implementation folder is untracked.

### Known gaps

- The implementation of ADR-0006 does not implement REQ-NFR-008 to REQ-NFR-010 (risk R-10). It passes version 1.0.0.

## [1.0.0] - 2026-11-22

### Added

- First complete spec at commit `5555a3f`: requirements (EARS), scenarios, state machines, architecture (domain model, C4, arc42, ADR-0001 to ADR-0008), design (UI/UX, LLD, OpenAPI, SQL schema, legacy import mapping), glossary and traceability.
