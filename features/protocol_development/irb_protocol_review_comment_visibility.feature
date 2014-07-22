@IRB
Feature: IRB Protocol Review Comment Visibility

  As an IRB Admin, I want to ensure Protocol review comments
  are visible, or not, to the appropriate personnel, because TBD...

  Background:
    * Users exist with the following roles: IRB Administrator, Protocol Creator
    * the IRB Admin creates a Committee
    * schedules at least one event for the Committee
    * adds four or more members to the Committee
    * submits the Committee
    * the Protocol Creator creates an IRB Protocol in the Committee's home unit
    * assigns a committee member the the Protocol's personnel
    * submits the Protocol to the Committee for review
    * assigns a primary and a secondary reviewer to the Protocol
    * edits the meeting details to make it available to reviewers
    * the primary reviewer submits review comments
  @test
  Scenario: Approved Primary Reviewer Comments are Private and Final
    Given the IRB Admin sets the flags of the primary reviewers comments to Private and Final
    And   the IRB Admin approves the primary reviewers review(s)
    When  the IRB Admin approves the primary reviewers comment(s)
    Then  the secondary reviewer can see the primary reviewer's comment in Submission Details
    And   the principal investigator can't see the primary reviewer's comment in Submission Details
    And   the non-reviewing committee member can't see the primary reviewer's comment in Submission Details
    And   the uninvolved committee member can see the primary reviewer's comment in Submission Details
    And   the secondary reviewer can see the primary reviewer's comment in the meeting minutes
    And   the primary reviewer can see the primary reviewer's comment in the meeting minutes
    And   the uninvolved committee member can see the primary reviewer's comment in the meeting minutes
    And   the non-reviewing committee member can't see the primary reviewer's comment in the meeting minutes

  Scenario: Approved Primary Reviewer Comments are Final, not Private
    Given the IRB Admin sets the flags of the primary reviewers comments to Final
    And   the IRB Admin approves the primary reviewers review(s)
    When  the IRB Admin approves the primary reviewers comment(s)
    Then  the secondary reviewer can see the primary reviewer's comment in Submission Details
    And   the principal investigator can see the primary reviewer's comment in Submission Details
    And   the non-reviewing committee member can see the primary reviewer's comment in Submission Details
    And   the uninvolved committee member can see the primary reviewer's comment in Submission Details

  Scenario: Approved Primary Reviewer Comments are Private, not Final
    Given the IRB Admin sets the flags of the primary reviewers comments to Private
    And   the IRB Admin approves the primary reviewers review(s)
    When  the IRB Admin approves the primary reviewers comment(s)
    Then  the secondary reviewer can't see the primary reviewer's comment in Submission Details
    And   the principal investigator can't see the primary reviewer's comment in Submission Details
    And   the non-reviewing committee member can't see the primary reviewer's comment in Submission Details
    And   the uninvolved committee member can't see the primary reviewer's comment in Submission Details

  Scenario: Approved Primary Reviewer Comments are not Private and not Final
    Given the IRB Admin sets the flags of the primary reviewers comments to clear
    And   the IRB Admin approves the primary reviewers review(s)
    When  the IRB Admin approves the primary reviewers comment(s)
    Then  the secondary reviewer can't see the primary reviewer's comment in Submission Details
    And   the principal investigator can't see the primary reviewer's comment in Submission Details
    And   the non-reviewing committee member in the Protocol's personnel can't see the primary reviewer's comment in Submission Details
    And   the uninvolved committee member can't see the primary reviewer's comment in Submission Details

  Scenario: Primary Reviewer Comments are Private and Final, but not Approved
    Given the IRB Admin sets the flags of the primary reviewers comments to Private and Final
    And   the IRB Admin approves the primary reviewers review(s)
    Then  the secondary reviewer can't see the primary reviewer's comment in Submission Details
    And   the principal investigator can't see the primary reviewer's comment in Submission Details
    And   the non-reviewing committee member in the Protocol's personnel can't see the primary reviewer's comment in Submission Details
    And   the uninvolved committee member can't see the primary reviewer's comment in Submission Details