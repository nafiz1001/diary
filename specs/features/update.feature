Feature: Update an entry
  As the user
  I want to correct the text of an entry
  So that the diary stays right

  Background:
    Given the diary has these entries:
      | text   | created_at          |
      | first  | 2026-01-05 15:30:00 |
      | second | 2026-01-06 09:00:00 |

  @REQ-UPD-001
  Scenario: The update page holds the current text
    When the user opens the update page of entry 2
    Then the form holds the text "second"

  @REQ-UPD-002
  Scenario: A valid text replaces the old text
    When the user updates entry 2 with the text "second, corrected"
    Then entry 2 has the text "second, corrected"
    And the update instant of entry 2 is within 5 seconds of now
    And the form holds the text "second, corrected"
    And the user is told that the entry was updated

  @REQ-UPD-003
  Scenario: The update page of a missing entry is not found
    When the user opens the update page of entry 99
    Then the system answers "not found"

  @REQ-UPD-003
  Scenario: An update of a missing entry is not found and changes nothing
    When the user updates entry 99 with the text "ghost"
    Then the system answers "not found"
    And the diary has 2 entries

  @REQ-UPD-004
  Scenario Outline: A whitespace-only text is rejected and the stored text stays
    When the user updates entry 2 with the text "<text>"
    Then the update is rejected with the reason "empty_text"
    And entry 2 has the text "second"
    And the form holds the text "<text>"

    Examples:
      | text                         |
      |                              |
      | {space}{space}               |
      | {tab}                        |
      | {space}{newline}{return}     |

  @REQ-UPD-005
  Scenario Outline: The updated text is stored exactly as entered
    When the user updates entry 2 with the text "<text>"
    Then entry 2 has the text "<text>"

    Examples:
      | text                     |
      | {space}{space}padded     |
      | line one{newline}line two |
      | tab{tab}separated        |
      | trailing{newline}        |

  @REQ-UPD-006 @manual
  Scenario: A second send is blocked while the first is in progress
    Given the user has sent the update form
    And the system has not yet answered
    When the user sends the update form again
    Then the system ignores the second send

  @REQ-UPD-007 @REQ-NFR-005
  Scenario: A store failure keeps the text and shows no success
    Given the entry store is unavailable
    When the user updates entry 2 with the text "second, corrected"
    Then the update fails with the reason "store_unavailable"
    And the form holds the text "second, corrected"
    And the user is not told that the entry was updated

  @REQ-UPD-008
  Scenario: An update keeps the id and the creation instant
    When the user updates entry 2 with the text "second, corrected"
    Then entry 2 has the creation instant "2026-01-06 09:00:00" UTC
    And the diary has 2 entries

  @REQ-UPD-002
  Scenario: An update does not change other entries
    When the user updates entry 2 with the text "second, corrected"
    Then entry 1 has the text "first"
