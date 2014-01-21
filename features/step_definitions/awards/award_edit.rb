#----------------------#
#Key Personnel
#----------------------#
Given /^I? ?add a PI to the Award$/ do
  # Note: the logic is here because of the nesting of this
  # step in "I complete the Award requirements"
  @award.add_pi if @award.key_personnel.principal_investigator.nil?
end

Given /adds the Funding Proposal's PI as the Award's PI/ do
  p_i = @institutional_proposal.key_personnel.principal_investigator
  @award.add_pi first_name: p_i.first_name, last_name: p_i.last_name
end

Given /I? ?add a key person to the Award$/ do
  @award.add_key_person
end

When /^I? ?add the (.*) unit to the Award's PI$/ do |unit|
  @award.key_personnel.principal_investigator.add_unit unit
end

When /^I? ?remove the (.*) unit from the Award's PI$/ do |unit|
  @award.key_personnel.principal_investigator.delete_unit unit
end

When /^I? ?add (.*) as the lead unit to the Award's PI$/ do |unit|
  @award.key_personnel.principal_investigator.add_lead_unit unit
end

When /^I? ?set (.*) as the lead unit for the Award's PI$/ do |unit|
  @award.key_personnel.principal_investigator.set_lead_unit unit
end


#----------------------#
#Subawards
#----------------------#
Given /^I? ?adds? a subaward to the Award$/ do
  @award.add_subaward
end

Given /I? ?add a \$(.*) Subaward for (.*) to the Award$/ do |amount, organization|
  @award.add_subaward organization, amount
end


#----------------------#
#Contacts
#----------------------#
Given /I? ?add a Sponsor Contact to the Award$/ do
  @award.add_sponsor_contact
end


#----------------------#
#Payment Info
#----------------------#
Given /I? ?add a Payment & Invoice item to the Award$/ do
  @award.add_payment_and_invoice
end

When /^I start adding a Payment & Invoice item to the Award$/ do
  @award.view :payment_reports__terms
  on PaymentReportsTerms do |page|
    r = '::random::'
    page.expand_all
    page.payment_basis.pick r
    page.payment_method.pick r
    page.payment_type.pick r
    page.frequency.pick r
    page.frequency_base.pick r
    page.osp_file_copy.pick r
    page.add_payment_type
  end
end

When /^I? ?give the Award valid credit splits$/ do
  @award.set_valid_credit_splits
end

When /I? ?add Reports to the Award$/ do
  # Logic is here because of this step's nesting in
  # "I complete the Award"
  @award.add_reports if @award.reports.nil?
end

When /I? ?add Terms to the Award$/ do
  @award.add_terms if @award.terms.nil?
end

When /I? ?add the required Custom Data to the Award$/ do
  @award.add_custom_data if @award.custom_data.nil?
end

When /completes? the Award requirements$/ do
  steps %q{
    And add Reports to the Award
    And add Terms to the Award
    And add the required Custom Data to the Award
    And add a Payment & Invoice item to the Award
    And add a Sponsor Contact to the Award
    And add a PI to the Award
    And give the Award valid credit splits
  }
end

When /^I? ?(?:creates? an Award for the Funding Proposal)|(?:links? the Funding Proposal to an Award)$/ do
  @award = create AwardObject
  @award.add_funding_proposal @institutional_proposal.proposal_number, '::random::'
end

When /^the (.*) adds the Institutional Proposal to the Award$/ do |role_name|
  steps %{ Given I log in with the #{role_name} user }
  @award = create AwardObject
  @award.add_funding_proposal @institutional_proposal.proposal_number, '::random::'
end

And /^the Institutional Proposal Maintainer can unlink the proposal$/ do
  steps 'Given I log in with the Institutional Proposal Maintainer user'
  expect{
    @institutional_proposal.unlock_award(@award.id)
  }.not_to raise_error
  on(InstitutionalProposalActions).errors.size.should == 0
end

Then /^the Institutional Proposal Maintainer cannot unlink the proposal$/ do
  steps 'Given I log in with the Institutional Proposal Maintainer user'
  @institutional_proposal.unlock_award(@award.id)
  on(InstitutionalProposalActions).errors.size.should > 0
end

Then /^the Institutional Proposal cannot be added to the Award$/ do
  pending
end