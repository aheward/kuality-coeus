@award @wip
Feature: Copying Awards

  Summary to be written

  Background:
    * a User exists with the role 'Time And Money Modifier' in unit '000001'
    * a User exists with the role 'Award Modifier' in unit 'CS'
    * the Award Modifier creates an Award
    * adds a subaward to the Award
    * completes the Award requirements
    * the Time & Money Modifier submits the Award's T&M document
    * the Award Modifier submits the Award

  Scenario: Award copied as new Parent
    When I copy the Award to a new parent Award
    Then the new Award should not have any subawards or T&M document
    And  the anticipated and obligated amounts are zero

  Scenario: Award copied to a child of itself
    When I copy the Award as a child of itself
    Then the child Award's project end date should be the same as the parent, and read-only
    And  the anticipated and obligated amounts are read-only and $0.00