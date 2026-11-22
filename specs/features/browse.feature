Feature: Browse entries
  As the user
  I want to read my entries in pages, newest first
  So that I can find what I wrote

  Background:
    Given an empty diary

  @REQ-BRW-001
  Scenario: Entries are listed newest first
    Given the diary has 25 numbered entries
    When the user opens the viewer
    Then the page shows the entries numbered 25 down to 16

  @REQ-BRW-001
  Scenario: Entries with the same instant are ordered by id, highest first
    Given the diary has these entries:
      | text  | created_at          |
      | one   | 2026-01-05 15:30:00 |
      | two   | 2026-01-05 15:30:00 |
      | three | 2026-01-05 15:30:00 |
    When the user opens the viewer
    Then the page shows the entries with these texts in order:
      | text  |
      | three |
      | two   |
      | one   |

  @REQ-BRW-002
  Scenario: The viewer uses the default limit and offset
    Given the diary has 25 numbered entries
    When the user opens the viewer
    Then the effective limit is 10
    And the effective offset is 0
    And the page shows 10 entries

  @REQ-BRW-003 @REQ-NFR-002
  Scenario Outline: The creation instant is shown in the display zone
    Given an entry created at "<utc>" UTC with the text "note"
    When the user opens the viewer
    Then the page shows the entry time "<shown>"

    Examples: Default display zone, winter and summer
      | utc                 | shown                    |
      | 2026-01-05 15:30:00 | 2026-01-05 (Mon) 10:30:00 |
      | 2026-07-01 12:00:00 | 2026-07-01 (Wed) 08:00:00 |
      | 2026-01-06 03:00:00 | 2026-01-05 (Mon) 22:00:00 |

  @REQ-NFR-002
  Scenario: A configured display zone replaces the default
    Given the display zone is "Asia/Tokyo"
    And an entry created at "2026-01-05 15:30:00" UTC with the text "note"
    When the user opens the viewer
    Then the page shows the entry time "2026-01-06 (Tue) 00:30:00"

  @REQ-NFR-001
  Scenario: Instants are stored in UTC whatever the display zone
    Given the display zone is "Asia/Tokyo"
    When the user submits the entry text "note"
    Then the stored creation instant of the newest entry, read as UTC, is within 5 seconds of now

  @REQ-BRW-003
  Scenario: Line breaks and spaces of the text are kept
    Given an entry created at "2026-01-05 15:30:00" UTC with the text "line one{newline}  line two"
    When the user opens the viewer
    Then the page shows the entry text "line one{newline}  line two"

  @REQ-BRW-003
  Scenario: Each entry links to its update page
    Given the diary has 3 numbered entries
    When the user opens the viewer
    Then each shown entry has a link to its update page

  @REQ-BRW-004
  Scenario Outline: A limit or offset out of range is clamped before entries are read
    Given the diary has 25 numbered entries
    When the user opens the viewer with limit "<limit>" and offset "<offset>"
    Then the effective limit is <effective_limit>
    And the effective offset is <effective_offset>
    And the page shows <shown> entries

    Examples:
      | limit | offset | effective_limit | effective_offset | shown |
      | 0     | 0      | 1               | 0                | 1     |
      | -5    | 0      | 1               | 0                | 1     |
      | 500   | 0      | 100             | 0                | 25    |
      | 10    | -3     | 10              | 0                | 10    |
      | 10    | 99     | 10              | 24               | 1     |
      | 10    | 24     | 10              | 24               | 1     |
      | abc   | 0      | 10              | 0                | 10    |
      | 10    | abc    | 10              | 0                | 10    |

  @REQ-BRW-004
  Scenario: The offset of an empty diary is 0
    When the user opens the viewer with limit "10" and offset "50"
    Then the effective offset is 0

  @REQ-BRW-005
  Scenario: The total is shown on every page
    Given the diary has 25 numbered entries
    When the user opens the viewer with limit "10" and offset "20"
    Then the viewer shows the total 25

  @REQ-BRW-006
  Scenario Outline: The next page link shows only while more entries follow
    Given the diary has 25 numbered entries
    When the user opens the viewer with limit "<limit>" and offset "<offset>"
    Then the viewer <next_link>

    Examples:
      | limit | offset | next_link                                    |
      | 10    | 0      | shows a link to the next page at offset 10   |
      | 10    | 10     | shows a link to the next page at offset 20   |
      | 10    | 15     | shows no link to the next page               |
      | 10    | 20     | shows no link to the next page               |
      | 25    | 0      | shows no link to the next page               |

  @REQ-BRW-007
  Scenario Outline: The latest and previous links show only away from offset 0
    Given the diary has 25 numbered entries
    When the user opens the viewer with limit "10" and offset "<offset>"
    Then the viewer <links>

    Examples:
      | offset | links                                                                    |
      | 0      | shows no link to the latest page and no link to the previous page        |
      | 5      | shows a link to the latest page and a link to the previous page at offset 0 |
      | 20     | shows a link to the latest page and a link to the previous page at offset 10 |

  @REQ-BRW-008
  Scenario: The user sets limit and offset in the viewer controls
    Given the diary has 25 numbered entries
    When the user sets the viewer controls to limit "5" and offset "10"
    Then the page shows the entries numbered 15 down to 11

  @REQ-BRW-009
  Scenario: An empty diary shows a message and no paging links
    When the user opens the viewer
    Then the viewer shows the message "No entries yet."
    And the viewer shows no link to the next page
    And the viewer shows no link to the latest page and no link to the previous page

  @REQ-NFR-003
  Scenario: Entry text is shown as plain text
    Given an entry created at "2026-01-05 15:30:00" UTC with the text "<b>bold</b> & <script>x</script>"
    When the user opens the viewer
    Then the page shows the entry text "<b>bold</b> & <script>x</script>" as plain text

  @REQ-NFR-004
  Scenario: The system reads the store location from configuration
    Given the entry store is configured at a location other than the default
    And an entry created at "2026-01-05 15:30:00" UTC with the text "note"
    When the system starts
    And the user opens the viewer
    Then the page shows 1 entry
    And no entry store exists at the default location

  @REQ-NFR-006 @manual
  Scenario: A page of a large diary arrives quickly
    Given the diary has 100000 numbered entries
    When the user opens the viewer with limit "100" and offset "50000"
    Then the page arrives in less than 1 second
