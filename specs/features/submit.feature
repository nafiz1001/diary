Feature: Submit an entry
  As the user
  I want to write a note and save it
  So that the diary keeps it with the time I wrote it

  Background:
    Given an empty diary

  @REQ-SUB-001
  Scenario: A valid text becomes an entry with the current time
    When the user submits the entry text "Went for a walk"
    Then the diary has 1 entry
    And the newest entry has the text "Went for a walk"
    And the creation instant of the newest entry is within 5 seconds of now

  @REQ-SUB-002
  Scenario Outline: A whitespace-only text is rejected
    When the user submits the entry text "<text>"
    Then the submission is rejected with the reason "empty_text"
    And the diary has 0 entries
    And the form still holds the text "<text>"

    Examples:
      | text                         |
      |                              |
      | {space}                      |
      | {space}{space}{space}        |
      | {tab}                        |
      | {newline}{newline}           |
      | {space}{tab}{newline}{space} |

  @REQ-SUB-003
  Scenario: A saved entry clears the form and confirms
    When the user submits the entry text "Went for a walk"
    Then the form is empty
    And the user is told that the entry was saved

  @REQ-SUB-004 @frontend @manual
  Scenario: A second send is blocked while the first is in progress
    Given the user has sent the form
    And the system has not yet answered
    When the user sends the form again
    Then the system ignores the second send
    And the diary has at most 1 entry

  @REQ-SUB-005
  Scenario Outline: The text is stored exactly as entered
    When the user submits the entry text "<text>"
    Then the newest entry has the text "<text>"

    Examples:
      | text                               |
      | {space}{space}padded{space}{space} |
      | line one{newline}line two          |
      | tab{tab}separated                  |
      | {space}{newline} trailing{newline} |

  @REQ-SUB-006
  Scenario: A store failure keeps the text
    Given the entry store is unavailable
    When the user submits the entry text "Went for a walk"
    Then the submission fails with the reason "store_unavailable"
    And the form still holds the text "Went for a walk"
