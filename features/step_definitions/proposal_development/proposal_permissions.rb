When /^I? ?visit the proposal's (.*) page$/ do |page|
  @proposal.view page
end

Then /^the (.*) user is listed as an? (.*) in the proposal permissions$/ do |username, role|
  on(Permissions).assigned_role(get(username).user_name).should include role
end

When /^I? ?assign the (.*) user as an? (.*) in the proposal permissions$/ do |system_role, role|
  set(system_role, (make UserObject, role: system_role))
  @proposal.permissions.send(snake_case(role+'s')) << get(system_role).user_name
  @proposal.permissions.assign
end

Then /^the (.*) user can access the proposal$/ do |role|
  get(role).sign_in
  @proposal.open_proposal
  on(Researcher).error_table.should_not be_present
end

Then /^their proposal permissions do not allow them to edit budget details$/ do
  lambda{@proposal.edit(project_title: 'edit')}.should_not raise_error
  lambda{@budget_version.open_budget}.should_not raise_error
  lambda{@budget_version.edit(total_direct_cost_limit: '100')}.should raise_error(Watir::Exception::UnknownObjectException, /unable to locate element/)
end

And /^their proposal permissions allow them to edit all parts of the proposal$/ do
  on Proposal do |page|
    page.save_button.should be_present
    page.abstracts_and_attachments
  end
  on AbstractsAndAttachments do |page|
    page.save_button.should be_present
    page.custom_data
  end
  on PDCustomData do |page|
    page.save_button.should be_present
    page.key_personnel
  end
  on KeyPersonnel do |page|
    page.save_button.should be_present
    page.permissions
  end
  on Permissions do |page|
    page.save_button.should be_present
    page.proposal_actions
  end
  on ProposalActions do |page|
    page.save_button.should be_present
    page.special_review
  end
  on SpecialReview do |page|
    page.save_button.should be_present
  end
end

And /^their proposal permissions allow them to update the budget, not the narrative$/ do
  expect{
    @proposal.add_proposal_attachment file_name: 'test.pdf', type: 'Narrative'
  }.should raise_error
  expect{@proposal.add_budget_version}.not_to raise_error
end

And /^their proposal permissions allow them to only read the proposal$/ do
  on Proposal do |page|
    page.save_button.should_not be_present
    page.abstracts_and_attachments
  end
  on AbstractsAndAttachments do |page|
    page.save_button.should_not be_present
    page.custom_data
  end
  on PDCustomData do |page|
    page.save_button.should_not be_present
    page.key_personnel
  end
  on KeyPersonnel do |page|
    page.save_button.should_not be_present
    page.permissions
  end
  on Permissions do |page|
    page.save_button.should_not be_present
    page.proposal_actions
  end
  on ProposalActions do |page|
    page.save_button.should_not be_present
    page.special_review
  end
  on SpecialReview do |page|
    page.save_button.should_not be_present
  end
end

And /^their proposal permissions allow them to delete the proposal$/ do
  on(Proposal).proposal_actions
  lambda{@proposal.delete}.should_not raise_error
end

Then /^there should be an error message that says not to select other roles alongside aggregator$/ do
  on(Roles).errors.should include 'Do not select other roles when Aggregator is selected.'
end

When /^I? ?attempt to add an additional proposal role to the (.*) user$/ do |system_role|
  if system_role=='Proposal Creator'
    role='aggregator'
  else
    role=system_role
  end
  role_to_add = ([:viewer, :budget_creator, :narrative_writer, :aggregator]-[StringFactory.damballa(role)]).sample
  on(Permissions).edit_role(get(system_role).user_name)
  on Roles do |page|
    page.use_new_tab
    page.send(role_to_add).set
    page.save
    # Note: This step def does not go beyond clicking the Save button here
    # because the expectation is that the Roles window will not close,
    # but will instead display an error message.
  end
end

Then /^the (.*) user should not be listed as an? (.*) in the second proposal$/ do |system_role, role|
  user = get(system_role)
  @proposal2.view :permissions
  on Permissions do |page|
    page.assigned_to_role(role).should_not include "#{user.first_name} #{user.last_name}"
  end
end
