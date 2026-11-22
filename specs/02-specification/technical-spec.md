# Technical specification

Phase 3 completes this file (configuration keys, date input rules, export grammar).

## Time rules (needed by submit)

| ID | Rule |
|----|------|
| TS-TIME-1 | The system keeps every Instant in UTC. |
| TS-TIME-2 | The system sets the creation instant when it stores the entry. |
| TS-TIME-3 | The creation instant has a resolution of at least one second. |
| TS-TIME-4 | The system never changes the creation instant of an entry. |

## Text rules (needed by submit)

| ID | Rule |
|----|------|
| TS-TEXT-1 | Entry text is a sequence of Unicode characters. |
| TS-TEXT-2 | The system stores the sequence unchanged, including line breaks, tabs and leading and trailing whitespace. |
| TS-TEXT-3 | Whitespace means space (U+0020), tab (U+0009), line feed (U+000A) and carriage return (U+000D). |
| TS-TEXT-4 | The system sets no maximum text length in version 1. |

## Non-functional needs (needed by submit)

| ID | Need |
|----|------|
| TS-NFR-1 | The submit flow works with no script support in the browser (see ADR-0004). |
| TS-NFR-2 | A submission that is valid is saved before the system confirms it. The system never shows "Entry saved." for an entry it did not store. |
| TS-NFR-3 | The system answers one submission in under 1 second on a personal machine with a diary of 100000 entries. |

## Scenario step conventions

1. Step text is domain language. It names no page element, route or status code.
2. In step text, `{space}` means a space, `{tab}` means a tab and `{newline}` means a line feed. This keeps whitespace visible, because Gherkin trims table cells and reads a backslash-n in a cell as a real line break.
3. A `@manual` scenario is skipped by the runner.
