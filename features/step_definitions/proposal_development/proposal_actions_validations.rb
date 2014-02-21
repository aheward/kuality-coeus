And /^I? ?activate a validation check$/ do
  on(Proposal).proposal_actions
  on ProposalActions do |page|
    page.show_data_validation
    page.turn_on_validation
  end
end

When /^the Proposal has no principal investigator$/ do
  #nothing needed for this step
end



Then /^one of the errors should say the investigators aren't all certified$/ do
  on(ProposalActions).validation_errors_and_warnings.should include "The Investigators are not all certified. Please certify #{@proposal.key_personnel[0].first_name}  #{@proposal.key_personnel[0].last_name}."
end

When /^I? ?do not answer my proposal questions$/ do
  #nothing necessary for this step
end

When /^I? ?creates? a Proposal with an un-certified (.*)$/ do |role|
  @role = role
  @proposal = create ProposalDevelopmentObject
  @proposal.add_key_person role: @role, certified: false
end

Given /^I? ?creates? a Proposal where the un-certified key person has included certification questions$/ do
  @role = 'Key Person'
  @proposal = create ProposalDevelopmentObject
  @proposal.add_key_person role: @role, key_person_role: 'default', certified: false
end