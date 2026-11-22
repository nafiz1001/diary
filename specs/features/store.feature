Feature: Schema version of the entry store
  As the operator
  I want the store to record its schema version
  So that an upgrade migrates my entries and an old system never damages a newer store

  # The step conventions 25 to 28 in the technical specification define the steps of this file.
  # The schema version of the system is 1 unless a scenario says other (TS-STORE-1).

  @REQ-NFR-008
  Scenario: A new store records the schema version
    Given an empty diary
    When the system starts
    Then the system starts
    And the store has schema version 1

  @REQ-NFR-008
  Scenario: The schema version stays when the system starts again on the same store
    Given a store with schema version 1
    And the diary has 3 numbered entries
    When the system starts
    Then the system starts
    And the store has schema version 1
    And the diary has 3 entries

  @REQ-NFR-009
  Scenario: A store with a newer schema version is refused and not changed
    Given a store with schema version 2
    And the diary has 3 numbered entries
    When the system starts
    Then the system does not start with the reason "schema_too_new"
    And the message names schema version 2
    And the store is unchanged

  @REQ-NFR-010
  Scenario: A store with an older schema version is migrated
    Given the system knows schema version 2
    And a store with schema version 1
    And the diary has 3 numbered entries
    When the system starts
    Then the system starts
    And the store has schema version 2
    And the diary has 3 entries

  @REQ-NFR-010
  Scenario: A failed migration leaves the store unchanged
    Given the system knows schema version 2
    And a store with schema version 1
    And the diary has 3 numbered entries
    And the migration to schema version 2 fails
    When the system starts
    Then the system does not start with the reason "migration_failed"
    And the store is unchanged
    And the store has schema version 1
