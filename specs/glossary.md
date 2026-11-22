# Glossary

One term has one meaning. Add terms here before other files use them.

| Term | Meaning |
|------|---------|
| Spec | The files in `specs/`. They name no programming language, framework or library. |
| Implementation | A program in `implementations/<stack>/` that satisfies the spec. |
| Legacy implementation | The code before the restart, tagged `legacy-v0.1.0`. A reference only. |
| Requirement | One testable statement in EARS form with a `REQ-` ID. |
| Scenario | One Gherkin example that checks a requirement. |
| Frontend scenario | A scenario tagged `@frontend @manual` that checks the user interface (ADR-0008). A person checks it unless a frontend runner runs it. |
| Runner | A program that runs scenarios or the contract test against an implementation. A domain runner skips `@manual`. A frontend runner drives the user interface. |
| Marker | A stable property of a page element (id, name, class, role or data attribute) that a runner uses to find it. |
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
| Update instant | The Instant of the last change of the entry text. Equals the creation instant until the first update. |
| Update | The act of the user replacing the text of an existing entry. |
| Viewer | The page that lists entries in pages. |
| Page | One slice of the diary that the viewer shows. Has a limit, an offset and the total. |
| Limit | The number of entries on a page. Default 10, range 1 to 100. |
| Offset | The number of entries before the first entry of a page, counted newest first. Default 0. |
| Total | The number of entries in the diary. |
| Calendar date | A date with no time and no zone. |
| Export | A file that holds entries, in Markdown or tab-separated form. |
| Export request | The date, order and format that the user chooses for an export. |
| Created since | The calendar date that starts an export. The system includes entries created at or after the start of that date in the display zone. |
| Legacy store | The entry store file of the legacy implementation. |
| Operator | The user, when the user runs the import tool. |
| Import | The one-time copy of all legacy entries into the new store. |
| Schema version | The whole number that the entry store records. It names the form of the schema in the store (ADR-0009). |
| Backup | A copy of the entry store file, and of the files with the same name prefix, made while the system is stopped. |
