@proposal_log
Feature: Creating Proposal Logs

  As a researcher I want the ability to create a Proposal Log document
  so that my institution can create an Institutional Proposal record apart
  from the KC Proposal Development and Budget modules.

  Background:
    * a User exists with the role: 'Create Proposal Log'
  #RESKC-663
  @system_failure
  Scenario: Attempt to create a new Proposal Log Document with a missing required field
    Given the Create Proposal Log user creates a Proposal Log but misses a required field
    When  the Create Proposal Log user submits the Proposal Log
    Then  an error should appear saying the field is required
  @smoke
  Scenario: Create a new Proposal Log Document
    When  the Create Proposal Log user creates a Proposal Log
    Then  the status of the Proposal Log should be INITIATED
    And   the Proposal Log status should be Pending

  Scenario: Merge a new Proposal Log with an existing Temporary Proposal Log
    Given the Create Proposal Log user submits a new temporary Proposal Log with a particular PI
    When  the Create Proposal Log user submits a new permanent Proposal Log with the same PI into routing
    And   merges the new proposal log with the previous temporary proposal log
    Then  the permanent Proposal Log should show it has merged with the temporary one