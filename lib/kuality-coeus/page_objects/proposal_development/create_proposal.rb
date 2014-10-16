class CreateProposal < BasePage

  expected_element :project_title

  new_error_messages

  buttons 'Cancel', 'Save and continue'

  element(:proposal_type) { |b| b.select(:name=>'document.developmentProposal.proposalTypeCode') }
  element(:lead_unit) { |b| b.select(:name=>'document.developmentProposal.ownedByUnitNumber') }
  element(:activity_type) { |b| b.select(:name=>'document.developmentProposal.activityTypeCode') }

  element(:project_start_date) { |b| b.psdf.focus; b.psdf }
  element(:project_end_date) { |b| b.pedf.focus; b.pedf }
  element(:project_title) { |b| b.textarea(name: 'document.developmentProposal.title') }

  element(:sponsor_code) { |b| b.text_field(name: 'document.developmentProposal.sponsorCode') }
  action(:lookup_sponsor) { |b| b.button(data_onclick: %|showLookupDialog("uk9itv5_quickfinder_act",true,"Uif-DialogGroup-Lookup");|).click; b.iframe(class: 'uif-iFrame uif-lookupDialog-iframe').wait_until_present }

  element(:psdf) { |b| b.text_field(name: 'document.developmentProposal.requestedStartDateInitial') }
  element(:pedf) { |b| b.text_field(name: 'document.developmentProposal.requestedEndDateInitial') }

  element(:date_picker) { |b| b.div(id: 'ui-datepicker-div') }

end