Given /^I am logged in as admin$/ do
  @user = make UserObject
  @user.sign_in unless @user.logged_in?
end

And /^I begin a proposal$/ do
  @proposal = create ProposalDevelopmentObject
end

When /^I begin a proposal without a (.*)$/ do |name|
  name=~/Type/ || name=='Lead Unit' ? value='select' : value=''
  field = StringFactory.damballa(name).to_sym
  @proposal = create ProposalDevelopmentObject, field=>value
end

Then /^I should see an error that says "(.* is a required field.)"$/ do |text|
  text=~/Description/ ? error='Document '+text : error=text
  on(Proposal) do |page|
    page.error_summary.wait_until_present(5)
    page.errors.should include error
  end
end

When /^I begin a proposal with an invalid sponsor code$/ do
  @proposal = create ProposalDevelopmentObject, :sponsor_code=>'000000'
end

Then /^I should see an error that says valid sponsor code required$/ do
  on(Proposal).errors.should include 'A valid Sponsor Code (Sponsor) must be selected.'
end

When /^I add key personnel without a proposal role$/ do
  @proposal = create KeyPersonObject :key_person_role=>''
end

Then /^I should see an error that says please select proposal role$/ do
  #pending
end

And /^I add (.*) (.*) as a (.*) to Key Personnel$/ do |fname, lname, proposal_role|
  @proposal.add_key_person first_name: fname, last_name: lname, role: proposal_role
end

And /^I add (.*) (.*) as a Key Person with a role of (.*)$/ do |fname, lname, kp_role|
  @proposal.add_key_person first_name: fname, last_name: lname, role: 'Key Person', key_person_role: kp_role
end

And /^I add a Key Person with a (.*) credit split of (.*)$/ do |cs_type, amount|
  @proposal.add_key_person cs_type.downcase.to_sym=>amount
end

When /^I try to add two Principal Investigators$/ do
  [{first_name: 'Dick', last_name: 'Keogh', role: 'Principal Investigator'},
   {first_name: 'Pam', last_name: 'Brown', role: 'Principal Investigator'}]
  .each { |opts| @proposal.add_key_person opts }
end