# This step mentions user roles because it best fits into the context of
# our 'Given we have users with the roles' step
When /^I? ?send a notification to the (.*) users?$/ do |role|
  role = role.split(', ')

  on(PDCustomData).proposal_actions
  on(ProposalActions).send_notification
  role.each do |role|
    user_name = get(role).user_name
    on(NotificationEditor).employee_search
    on PersonLookup do |page|
      page.user_name.set user_name
      page.search
      page.return_value user_name
    end
    on(NotificationEditor).add
  end
  on(NotificationEditor).send_fyi
end

Then /^the Proposal status should be (.*)$/ do |status|
  @proposal.status.should == status
end

Then /^I should receive an action list item with the requested action being: (.*)$/ do |action|
  visit ActionList do |page|
    page.last if page.last_button.present?
    # This code is needed because the list refresh
    # may not happen immediately...
    x = 0
    while x < 4
      break if page.item_row(@proposal.document_id.to_i + 1).exists?
      sleep 1
    # The page refresh is necessary because the proposal
    # may reach the user's action list with delay
      page.refresh
    # After a refresh, you'll need to visit the last page
    # again to view most recent proposals
      page.last
      x += 1
    end
    page.action_requested(@proposal.document_id.to_i + 1).should == action
  end
end

Then /^I can acknowledge the requested action list item$/ do
  on ActionList do |page|
    page.action(@proposal.document_id.to_i + 1).select 'FYI'
    page.take_actions
  end
end

When /^I submit the Proposal to its sponsor$/ do
  @proposal.submit :to_sponsor
  @institutional_proposal = @proposal.make_institutional_proposal
end

And /^the (.*) submits the Proposal to its sponsor$/ do |role_name|
  steps %{ Given I log in with the #{role_name} user }
  @proposal.view :proposal_actions
  @proposal.submit :to_sponsor
  @institutional_proposal = @proposal.make_institutional_proposal
end

When /^I? ?submit the Proposal to S2S$/ do
  @proposal.submit :to_s2s
end

When /^I? ?blanket approve the Proposal$/ do
  @proposal.blanket_approve
end

And /^the principal investigator approves the Proposal$/ do
  $users.logged_in_user.sign_out unless $users.current_user==nil
  visit Login do |log_in|
    log_in.username.set @proposal.key_personnel.principal_investigator.user_name
    log_in.login
  end
  steps '* I can access the proposal from my action list'
  on(ProposalSummary).approve
  visit(Researcher).logout
end

And /^the OSP Approver approves the Proposal (with|without) future approval requests$/ do |future_requests|
  steps %{ Given I log in with the OSPApprover user }
  conf = {'with' => :yes, 'without' => :no}
  steps '* I can access the proposal from my action list'
  on(ProposalSummary).approve
  on(Confirmation).send(conf[future_requests])
end

And /^I approve the Proposal with future approval requests$/ do
  @proposal.view :proposal_summary
  on(ProposalSummary).approve
  on(Confirmation).yes
end

Then /^I should only have the option to submit the proposal to its sponsor$/ do
  @proposal.view :proposal_actions
  on ProposalActions do |page|
    page.approve_button.should_not be_present
    page.submit_to_sponsor_button.should be_present
  end
end

Then /^I should see the option to approve the Proposal$/ do
  @proposal.view :proposal_actions
  on ProposalActions do |page|
    page.approve_button.should be_present
  end
end

Then /^I should not see the option to approve the Proposal$/ do
  @proposal.view :proposal_actions
  on ProposalActions do |page|
    page.approve_button.should_not be_present
  end
end

And(/^I approve the Proposal$/) do
  @proposal.view :proposal_summary
  on(ProposalSummary).approve
end