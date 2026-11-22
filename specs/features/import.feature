Feature: Import the legacy store once
  As the operator
  I want to copy my old entries into the new store
  So that I keep my history after the restart

  # The legacy store keeps creation instants as UTC text with no zone marker,
  # for example "2026-01-05 15:30:00.123456". Ids are integers.

  Background:
    Given an empty diary

  @REQ-IMP-001 @REQ-IMP-004
  Scenario: Every legacy entry is copied with its id, text and creation instant
    Given a legacy store with these entries:
      | id | text   | created_at                 |
      | 3  | first  | 2026-01-05 15:30:00.123456 |
      | 7  | second | 2026-01-06 09:00:00        |
    When the operator imports the legacy store
    Then the import succeeds
    And the import reports 2 entries copied
    And the diary has 2 entries
    And entry 3 has the text "first"
    And entry 3 has the creation instant "2026-01-05 15:30:00" UTC
    And entry 7 has the text "second"
    And entry 7 has the creation instant "2026-01-06 09:00:00" UTC

  @REQ-IMP-001
  Scenario: The update instant equals the creation instant
    Given a legacy store with these entries:
      | id | text  | created_at          |
      | 3  | first | 2026-01-05 15:30:00 |
    When the operator imports the legacy store
    Then entry 3 has an update instant equal to its creation instant

  @REQ-IMP-001
  Scenario: A legacy entry with whitespace-only text is copied unchanged
    Given a legacy store with these entries:
      | id | text         | created_at          |
      | 1  | {space}{space} | 2026-01-05 15:30:00 |
    When the operator imports the legacy store
    Then the import succeeds
    And entry 1 has the text "{space}{space}"

  @REQ-IMP-002
  Scenario: A second import is refused
    Given a legacy store with these entries:
      | id | text  | created_at          |
      | 3  | first | 2026-01-05 15:30:00 |
    And the operator has imported the legacy store
    When the operator imports the legacy store
    Then the import is refused with the reason "target_not_empty"
    And the diary has 1 entry

  @REQ-IMP-002
  Scenario: A store that already holds an entry refuses the import
    Given a legacy store with these entries:
      | id | text  | created_at          |
      | 3  | first | 2026-01-05 15:30:00 |
    And an entry created at "2026-02-01 10:00:00" UTC with the text "new"
    When the operator imports the legacy store
    Then the import is refused with the reason "target_not_empty"
    And the diary has 1 entry

  @REQ-IMP-003
  Scenario: A missing legacy file fails with a reason
    Given no legacy store file exists
    When the operator imports the legacy store
    Then the import fails with the reason "legacy_unreadable"
    And the diary has 0 entries

  @REQ-IMP-003
  Scenario: A legacy file with no entry table fails with a reason
    Given a legacy store file that has no entry table
    When the operator imports the legacy store
    Then the import fails with the reason "legacy_table_missing"
    And the diary has 0 entries

  @REQ-IMP-005
  Scenario: One bad legacy entry undoes the whole import
    Given a legacy store with these entries:
      | id | text   | created_at          |
      | 1  | first  | 2026-01-05 15:30:00 |
      | 2  | second | not-a-time          |
      | 3  | third  | 2026-01-07 15:30:00 |
    When the operator imports the legacy store
    Then the import fails with the reason "entry_invalid"
    And the diary has 0 entries

  @REQ-IMP-006
  Scenario: A legacy creation instant with no zone marker is read as UTC
    Given a legacy store with these entries:
      | id | text  | created_at          |
      | 1  | first | 2026-07-01 12:00:00 |
    When the operator imports the legacy store
    Then entry 1 has the creation instant "2026-07-01 12:00:00" UTC

  @REQ-IMP-007
  Scenario: The legacy file is not changed
    Given a legacy store with these entries:
      | id | text  | created_at          |
      | 1  | first | 2026-01-05 15:30:00 |
    When the operator imports the legacy store
    Then the legacy store is unchanged
