Then /^I should see an error that the credit split is not a valid percentage$/ do
  on(KeyPersonnel).combined_credit_split_errors.should include 'Credit Split is not a valid percentage.'
end

Then /^I should see an error that only one PI is allowed$/ do
  on(KeyPersonnel).add_validation_errors.should include 'Only one proposal role of Principal Investigator is allowed.'
end
When /^I add a key person without a key person role$/ do
  @proposal.add_key_person first_name: 'Dick', last_name: 'COIAdmin' ,role: 'Key Person', key_person_role:''
end
Then /^I should see an error that says proposal role is required$/ do
  on(KeyPersonnel).add_validation_errors.should include 'Key Person Role is a required field.'
end
When /^I add a co-investigator without a unit$/ do
  @proposal.add_key_person first_name: 'Jeff', last_name: 'Covey', role: 'Co-Investigator'
  #TODO Create a method for deleting units, as they are related to Co-Investigator
end
Then /^I should see a key personnel error that says at least one unit is required$/ do
  on(KeyPersonnel).add_validation_errors.should include 'At least one Unit is required for Dick COIAdmin.'
end
