# ADR-0005: Single-file relational database with a standard SQL schema

- Status: accepted
- Date: 2026-11-22

## Context and problem statement

One user on one machine needs durable storage with no server to run.
The legacy store is a single-file relational database. The spec must stay stack-neutral.

## Considered options

1. Plain files (one file per entry, or one log file).
2. A single-file relational database.
3. A database server.

## Decision outcome

Chosen option: 2.

- The schema is standard SQL DDL in `04-design/data/schema.sql`. It uses no vendor types.
- An implementation may translate syntax that standard SQL leaves open (for example the identity column form).
  The table and column names, types and constraints stay the same.
- All Instants are stored in UTC.

## Consequences

- Good: no server. One file to back up. Queries for paging and ordering are simple.
- Good: the legacy store can be imported once (ADR-0007, written in phase 4).
- Bad: one writer at a time. This is fine for one user.
