Feature: Special Review Validations

  As a researcher I want to know if there are problems
  with my proposal's key personnel so that I can fix them
  before I submit the proposal

  Background: Necessary users exist in the system
    Given   I'm logged in with admin

  Scenario: The application date must be prior to the approval date
    When    I add a special review item that has an approval date earlier than the application date
    Then    I should see an error that the approval should occur later than the application