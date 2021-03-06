@award
Feature: Sponsor Term Creation

  As an Application Administrator,
  I want the ability to create and modify Sponsor Terms
  that I may use to link to a Sponsor Template.

  Background: Establish an Application Administrator user
    Given a User exists with the role: 'Application Administrator'

  Scenario: Submit a new Sponsor Term with a missing required field
    When the Application Administrator user submits a new Sponsor Term with a missing required field
    Then an error should appear saying the field is required