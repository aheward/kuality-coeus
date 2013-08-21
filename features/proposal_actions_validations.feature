Feature: Proposal Actions Validations

  As a researcher I want to know if my proposal contains any errors
  so that I can fix them prior to submitting my proposal

  Background: KC user is logged in as admin
      Given   I'm logged in with admin
    @test
    Scenario: Validate a proposal without a principal investigator
      Given   I begin a proposal
      And     the proposal has no principal investigator
      When    I activate a validation check
      Then    the validation error should say there is no principal investigator
      And     checking the key personnel page should show an error that says there is no principal investigator

    Scenario: Validate a proposal with no proposal questions answered
      Given   I begin a proposal
      And     I do not answer my proposal questions
      When    I activate a validation check
      Then    the validation error should say proposal questions were not answered
      And     checking the questions page shows an error that says proposal questions were not answered

    Scenario: Validate a proposal with an incomplete S2S FAT & Flat questionnaire
      Given   I begin a proposal
      And     I do not complete the S2S FAT & Flat questionnaire
      When    I activate a validation check
      Then    the validation error should say questionnaire must be completed
      And     checking the questions page shows an error that says questionnaire must be completed

    Scenario: Validate a proposal without incomplete compliance questions
      Given   I begin a proposal
      And     I do not complete the compliance question
      When    I activate a validation check
      Then    the validation error should say you must complete the compliance question
      And     checking the questions page shows an error that says you must complete the compliance question

    Scenario: Validate a proposal without unanswered Kuali University questions
      Given   I begin a proposal
      And     I do not complete the kuali university questions
      When    I activate a validation check
      Then    the validation should report the question was not answered
      And     checking the questions page should show the question was not answered

    Scenario: Validate a proposal without a sponsor deadline date
      Given   I begin a proposal without a sponsor deadline date
      When    I activate a validation check
      Then    the validation error should say sponsor deadline date not entered
      And     checking the proposal page shows an error that says sponsor deadline date not entered

    Scenario: Validate proposal with an un-certified co-investigator
      Given   I begin a proposal with an un-certified Co-Investigator
      When    I activate a validation check
      Then    the validation error should say the investigator needs to be certified
      And     checking the key personnel page shows a proposal person certification error that says the investigator needs to be certified

    Scenario: Validate a proposal with an un-certified principal investigator
      Given   I begin a proposal with an un-certified Principal Investigator
      When    I activate a validation check
      Then    the validation error should say the principal needs to be certified
      And     checking the key personnel page shows a proposal person certification error that says the investigator needs to be certified

    Scenario: Validate a proposal with an un-certified key person
      Given   I begin a proposal where the un-certified key person has certification questions
      When    I activate a validation check
      Then    the validation error should say the key person needs to be certified
      And     checking the key personnel page shows a proposal person certification error that says the investigator needs to be certified