# Glossary

One term has one meaning. Add terms here before other files use them.

| Term | Meaning |
|------|---------|
| Spec | The files in `specs/`. They name no programming language, framework or library. |
| Implementation | A program in `implementations/<stack>/` that satisfies the spec. |
| Legacy implementation | The code before the restart, tagged `legacy-v0.1.0`. A reference only. |
| Requirement | One testable statement in EARS form with a `REQ-` ID. |
| Scenario | One Gherkin example that checks a requirement. |
| ADR | Architecture decision record. One file per decision. |
| User | The one person who uses the diary. |
| Diary | The set of all entries. |
| Entry | One diary note with an id, text and a creation instant. |
| Entry text | The words of an entry, kept exactly as the user entered them. |
| Whitespace only | A text that has no character other than space, tab, carriage return and line feed. An empty text is also whitespace only. |
| Instant | A point in time, stored in UTC. |
| Creation instant | The Instant when the system stored the entry. |
| Display zone | The time zone used to show an Instant to the user. Default `America/Montreal`. |
| Submission | The act of the user sending entry text to the system to create an entry. |
| Entry store | The place where the system keeps entries. |
| Form | The page element where the user types entry text. |
