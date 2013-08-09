Feature: Validating content of s2s proposals

  As someone who submits proposals to the federal government for grant money
  I want to ensure the proposals are free of errors prior to submission

  Background: Logged in with a proposal creator; initiate a proposal for grants.gov
    Given a user exists with the system role: 'Proposal Creator'
    And   I log in with the Proposal Creator user
    And   initiate a proposal with a 'Federal' sponsor type
    And   add the Grants.Gov opportunity id of PA-B2-ALL to the proposal

  Scenario: Adding the opportunity
    Then  the opportunity details should appear on the page
    And   the 'remove opportunity' button should be present

  Scenario: Enter wrong revision type information
    Given I select a revision type of 'Increase Award'
    And   enter a 'revision specify' description
    When  I save the proposal
    Then  an error message appears saying that I need to select the 'Other' revision type

  Scenario: Don't enter S2S Revision Type for a revision proposal
    Given I set the proposal type to 'Revision'
    When  I go to the proposal's S2S page
    And   save the proposal
    Then  an error message appears saying a revision type must be selected
   @test
   Scenario: Select 'Change' for a new S2S proposal
     Given I select a submission type of 'Change/Corrected Application'
     When  I activate a validation check
     Then  one of the validation errors should say that an original proposal ID is needed