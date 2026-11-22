# Architecture (arc42)

Sections 1 to 5 are written. Phase 4 completes sections 6 to 12.

## 1. Introduction and goals

- Purpose: a personal diary for one user. See `../01-requirements/vision.md`.
- Top quality goals: simplicity, correct text and time handling, portability of the spec across stacks.
- Stakeholder: the user (reads, writes) and the developer (extends, ports).

## 2. Constraints

- The spec names no programming language, framework or library (ADR-0003).
- Data lives in one single-file relational database (ADR-0005).
- The user interface is a web browser (ADR-0004).
- The system runs on one personal machine for one user.

## 3. Context and scope

See `c4.md`, level 1.

| Neighbour | Exchange |
|-----------|----------|
| User | Sends entry text. Receives pages and files. |
| Web browser | Carries HTTP between the user and the system. |

Out of scope: sign-in, sharing, sync (see the vision).

## 4. Solution strategy

| Goal | Approach |
|------|----------|
| Simple | One application, one database file. |
| Works without script | Server-rendered pages. Forms post and redirect (ADR-0004). |
| Portable spec | Gherkin scenarios and an OpenAPI contract that each implementation runs (ADR-0003). |
| Correct time | Store UTC. Convert to the display zone only when showing. |

## 5. Building block view

Level 1 (see `c4.md`, level 2):

| Block | Responsibility |
|-------|----------------|
| Diary application | Receive requests, check rules, read and write entries, render pages. |
| Entry store | Keep entries durable. Schema in `../04-design/data/schema.sql`. |

Phase 4 adds level 2 (components).

## 6 to 12

Written in phase 4.
