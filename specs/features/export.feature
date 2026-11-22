Feature: Export entries
  As the user
  I want to take my entries out as a file
  So that I can keep or process them elsewhere

  # Time zone in all scenarios: the default display zone, America/Montreal.
  # Winter offset -0500, summer offset -0400.

  @REQ-EXP-001
  Scenario: The export page offers the choices
    When the user opens the export page
    Then the export page asks for a "created since" date
    And the export page offers the formats "Markdown" and "tab-separated"
    And the export page offers the orders "ascending" and "descending"
    And the order "ascending" is chosen

  @REQ-EXP-002
  Scenario: An export starts at the beginning of the date in the display zone
    Given the diary has these entries:
      | text    | created_at          |
      | before  | 2026-01-05 04:59:59 |
      | exactly | 2026-01-05 05:00:00 |
      | after   | 2026-01-05 15:30:00 |
    When the user exports entries created since "2026-01-05" as "markdown"
    Then the exported texts are in order:
      | text    |
      | exactly |
      | after   |

  @REQ-EXP-003
  Scenario: The export is oldest first when no order is given
    Given the diary has these entries:
      | text   | created_at          |
      | newer  | 2026-01-07 12:00:00 |
      | older  | 2026-01-06 12:00:00 |
    When the user exports entries created since "2026-01-01" as "tsv"
    Then the exported texts are in order:
      | text  |
      | older |
      | newer |

  @REQ-EXP-003
  Scenario: The export is newest first when the user chooses descending
    Given the diary has these entries:
      | text   | created_at          |
      | older  | 2026-01-06 12:00:00 |
      | newer  | 2026-01-07 12:00:00 |
    When the user exports entries created since "2026-01-01" as "tsv" in "descending" order
    Then the exported texts are in order:
      | text  |
      | newer |
      | older |

  @REQ-EXP-004
  Scenario: A Markdown export has a header, a separator and one row per entry
    Given an entry created at "2026-01-06 03:00:00" UTC with the text "hello"
    When the user exports entries created since "2026-01-01" as "markdown"
    Then the file is named "diary.md" with the media type "text/markdown"
    And the file content is:
      """
      |created_at|entry_text|
      |-|-|
      |2026-01-05T22:00:00-0500|hello|
      """

  @REQ-EXP-005
  Scenario: A tab-separated export has a header and one row per entry
    Given an entry created at "2026-01-06 03:00:00" UTC with the text "hello"
    When the user exports entries created since "2026-01-01" as "tsv"
    Then the file is named "diary.tsv" with the media type "text/tab-separated-values"
    And the file content is:
      """
      created_at{tab}entry_text
      2026-01-05T22:00:00-0500{tab}hello
      """

  @REQ-EXP-006
  Scenario Outline: A Markdown export escapes special characters
    Given an entry created at "2026-01-06 03:00:00" UTC with the text "<text>"
    When the user exports entries created since "2026-01-01" as "markdown"
    Then the file content is:
      """
      |created_at|entry_text|
      |-|-|
      |2026-01-05T22:00:00-0500|<escaped>|
      """

    Examples:
      | text                                | escaped                                      |
      | a{pipe}b                            | a{backslash}{pipe}b                          |
      | a{backslash}b                       | a{backslash}{backslash}b                     |
      | line one{newline}line two           | line one{backslash}nline two                 |
      | cr{return}here                      | cr{backslash}rhere                           |
      | tab{tab}here                        | tab{backslash}there                          |
      | {backslash}n is not a line break    | {backslash}{backslash}n is not a line break  |

  @REQ-EXP-007
  Scenario Outline: A tab-separated export escapes special characters and does not quote
    Given an entry created at "2026-01-06 03:00:00" UTC with the text "<text>"
    When the user exports entries created since "2026-01-01" as "tsv"
    Then the file content is:
      """
      created_at{tab}entry_text
      2026-01-05T22:00:00-0500{tab}<escaped>
      """

    Examples:
      | text                                | escaped                                      |
      | a{backslash}b                       | a{backslash}{backslash}b                     |
      | line one{newline}line two           | line one{backslash}nline two                 |
      | cr{return}here                      | cr{backslash}rhere                           |
      | tab{tab}here                        | tab{backslash}there                          |
      | say "hi"                            | say "hi"                                     |
      | a{pipe}b                            | a{pipe}b                                     |

  @REQ-EXP-008
  Scenario Outline: The creation instant is written in the display zone with its offset
    Given an entry created at "<utc>" UTC with the text "note"
    When the user exports entries created since "2026-01-01" as "tsv"
    Then the file content is:
      """
      created_at{tab}entry_text
      <written>{tab}note
      """

    Examples:
      | utc                 | written                  |
      | 2026-01-05 15:30:00 | 2026-01-05T10:30:00-0500 |
      | 2026-07-01 12:00:00 | 2026-07-01T08:00:00-0400 |

  @REQ-EXP-009
  Scenario Outline: A missing or invalid date or format delivers no file
    Given an entry created at "2026-01-06 03:00:00" UTC with the text "hello"
    When the user requests an export with the date "<date>" and the format "<format>"
    Then no file is delivered
    And the export page is shown with a message

    Examples:
      | date       | format   |
      |            | markdown |
      | not-a-date | markdown |
      | 2026-02-30 | markdown |
      | 2026-01-01 |          |
      | 2026-01-01 | pdf      |

  @REQ-EXP-010
  Scenario: An export with no matching entry has only the header rows
    Given an entry created at "2026-01-06 03:00:00" UTC with the text "hello"
    When the user exports entries created since "2026-02-01" as "markdown"
    Then the file content is:
      """
      |created_at|entry_text|
      |-|-|
      """
