# Vision

## Goal

The diary lets one person write short dated notes, find them again, correct them and take them out as files.

## Stakeholder

One local user. The user runs the diary on a personal machine and opens it in a web browser.
There is no sign-in, no sharing and no second user.

## Scope (version 1)

The current features of the legacy implementation, with its known defects fixed:

1. Submit an entry.
2. Browse entries, newest first, in pages.
3. Update the text of an entry.
4. Export entries as Markdown or tab-separated text.
5. Import the entries of the legacy store once, into the new schema.

## Non-goals

- Several users, accounts or permissions.
- Search, tags, attachments or rich text.
- Delete of an entry.
- Sync with another device or service.

## Success criteria

- Every requirement has a scenario that passes in each implementation.
- A new implementation in another stack needs no change to the spec.
