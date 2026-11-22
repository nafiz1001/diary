@frontend @manual
Feature: Form states in the user interface
  As the user
  I want the form to show what happens to my text while it is sent
  So that I never lose text and never send it twice

  Frontend scenarios for the form state machine in 04-design/ui-ux.md (ADR-0008).
  The double send scenarios are in submit.feature and update.feature.

  Background:
    Given the diary has 1 numbered entries
    And the enhanced send is on

  @REQ-SUB-004 @REQ-UPD-006
  Scenario Outline: The form shows that a send is in progress
    Given the system answers slowly
    And the user has the <form> open
    When the user enters "Walk" and sends the form
    Then before the answer the send control is disabled
    And before the answer the user is told "<sending>"
    And before the answer the entry text control holds "Walk"

    Examples:
      | form                   | sending       |
      | submit form            | Submitting... |
      | update form of entry 1 | Updating...   |

  @REQ-SUB-003 @REQ-UPD-002
  Scenario Outline: A saved send shows the outcome on the same page
    Given the user has the <form> open
    When the user enters "Walk" and sends the form
    Then the entry text control holds "<text after>"
    And the user is told "<saved>"
    And the send control is enabled
    And the page has not changed

    Examples:
      | form                   | text after | saved          |
      | submit form            |            | Entry saved.   |
      | update form of entry 1 | Walk       | Entry updated. |

  @REQ-SUB-002 @REQ-UPD-004
  Scenario Outline: A rejected send keeps the text and moves the focus to it
    Given the user has the <form> open
    When the user enters "{space}{space}{space}" and sends the form
    Then the entry text control holds "{space}{space}{space}"
    And the user is alerted "<rejected>" with the reason "empty_text"
    And the focus is on the entry text control
    And the send control is enabled
    And the diary is unchanged

    Examples:
      | form                   | rejected                           |
      | submit form            | Write some text before you submit. |
      | update form of entry 1 | Write some text before you update. |

  @REQ-SUB-006 @REQ-UPD-007 @REQ-NFR-005
  Scenario Outline: A store failure keeps the text and moves the focus to it
    Given the entry store is unavailable
    And the user has the <form> open
    When the user enters "Walk" and sends the form
    Then the entry text control holds "Walk"
    And the user is alerted "<failed>" with the reason "store_unavailable"
    And the focus is on the entry text control
    And the send control is enabled
    And the user is not told "<saved>"

    Examples:
      | form                   | failed                                | saved          |
      | submit form            | The entry was not saved. Try again.   | Entry saved.   |
      | update form of entry 1 | The entry was not updated. Try again. | Entry updated. |

  @REQ-SUB-006 @REQ-UPD-007
  Scenario Outline: A lost connection keeps the text and moves the focus to it
    Given the user has the <form> open
    And the connection to the system is lost
    When the user enters "Walk" and sends the form
    Then the entry text control holds "Walk"
    And the user is alerted "<failed>"
    And the focus is on the entry text control
    And the send control is enabled
    And the user is not told "<saved>"

    Examples:
      | form                   | failed                                | saved          |
      | submit form            | The entry was not saved. Try again.   | Entry saved.   |
      | update form of entry 1 | The entry was not updated. Try again. | Entry updated. |

  @REQ-SUB-006 @REQ-UPD-007
  Scenario Outline: The user can send again after a failure
    Given the entry store is unavailable
    And the user has the <form> open
    And the user has entered "Walk" and sent the form
    When the entry store is available again
    And the user enters "Again" and sends the form
    Then the user is told "<saved>"

    Examples:
      | form                   | saved          |
      | submit form            | Entry saved.   |
      | update form of entry 1 | Entry updated. |
