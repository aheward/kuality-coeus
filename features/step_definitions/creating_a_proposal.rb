Given /^I am logged in as admin$/ do
  @user = make UserObject
  @user.sign_in
end
When /^I create a proposal$/ do
  @proposal = create ProposalDevelopmentObject
end
Then /^It's created$/ do
  on(Proposal).feedback.should=='Document was successfully saved.'
end