@frontend @manual @REQ-NFR-007
Feature: Accessibility
  As the user
  I want every page to work with the keyboard and assistive technology
  So that I can use the diary in the way that suits me

  Frontend scenarios for the accessibility rules 1 to 8 in 04-design/ui-ux.md (ADR-0008).

  Scenario Outline: Every page state meets the page-wide rules
    Given the user is on the <page state>
    When an automated WCAG 2.2 level A and AA check runs on the page
    Then the check finds no violation
    And the page has exactly 1 main heading
    And every text and control has a contrast ratio of at least 4.5:1 against its background

    Examples:
      | page state                                              |
      | submit page                                             |
      | submit page after a rejected send                       |
      | viewer of a diary with 12 numbered entries at offset 1  |
      | viewer of an empty diary                                |
      | update page of entry 1 of 1 numbered entries            |
      | update page of entry 1 after a rejected send            |
      | export page                                             |
      | export page after a request with no date                |
      | update page of an entry that does not exist             |

  Scenario Outline: Every form control has a visible linked label
    Given the user is on the <page state>
    Then every form control has a visible label
    And selecting a label moves the focus to its control

    Examples:
      | page state                                              |
      | submit page                                             |
      | viewer of a diary with 12 numbered entries at offset 1  |
      | update page of entry 1 of 1 numbered entries            |
      | export page                                             |

  Scenario Outline: Messages are announced
    Given the user is on the <page state>
    Then the <message> is a live region of the kind "<kind>"

    Examples:
      | page state                                   | message        | kind   |
      | submit page after a saved send               | status message | status |
      | submit page after a rejected send            | status message | alert  |
      | update page of entry 1 after a saved send    | status message | status |
      | update page of entry 1 after a rejected send | status message | alert  |
      | export page after a request with no date     | export message | alert  |

  Scenario Outline: After an error the focus is on the control to fix
    Given the enhanced send is off
    And the user is on the <page state>
    Then the focus is on the <control>
    And the <control> holds the value that the user sent

    Examples:
      | page state                                   | control                  |
      | submit page after a rejected send            | entry text control       |
      | update page of entry 1 after a rejected send | entry text control       |
      | export page after a request with no date     | created since control    |

  Scenario: Every task works with the keyboard only
    Given the diary has 12 numbered entries
    When the user uses only the keyboard
    Then the user can write and send an entry
    And the user can open the viewer and follow the links Next, Previous and Latest
    And the user can open an update page, change the text and send it
    And the user can request an export
    And the focus is always visible
    And no control traps the focus

  Scenario: Every task works with no optional behaviour
    Given the diary has 12 numbered entries
    And the enhanced send is off
    Then the user can write and send an entry
    And the user can open the viewer and follow the links Next, Previous and Latest
    And the user can open an update page, change the text and send it
    And the user can request an export

  @REQ-BRW-003
  Scenario: The entry table has column headers
    Given the user is on the viewer of a diary with 12 numbered entries at offset 1
    Then each column of the entry table has a header that applies to it
    And the column headers are "Time", "Note" and "Actions"

  @REQ-BRW-003 @REQ-NFR-003
  Scenario: Entry text keeps its line breaks and spaces and wraps
    Given an entry created at "2026-01-05 15:30:00" UTC with the text "line one{newline}{space}{space}line two"
    And an entry created at "2026-01-05 15:31:00" UTC with a text of 300 letters and no space
    When the user opens the viewer
    Then the entry with "line one" shows on 2 lines with its 2 leading spaces on the second line
    And the long text wraps inside its cell
    And the page has no horizontal scroll
