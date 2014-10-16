class ProposalDetails < BasePage

  new_doc_header
  document_buttons
  new_error_messages
  
  element(:doc_title) { |b| b.h1(id: 'PropDev-DefaultView_header').span.text }

  element(:proposal_type) { |b| b.select(name: 'document.developmentProposal.proposalTypeCode') }
  value(:lead_unit) { |b| b.div(data_label: 'Lead Unit').text }
  element(:activity_type) { |b| b.select(name: 'document.developmentProposal.activityTypeCode') }
  element(:project_start_date) { |b| b.text_field(name: 'document.developmentProposal.requestedStartDateInitial') }
  element(:project_end_date) { |b| b.text_field(name: 'document.developmentProposal.requestedEndDateInitial') }
  element(:project_title) { |b| b.textarea(name: 'document.developmentProposal.title') }
  element(:sponsor) { |b| b.text_field(name: 'document.developmentProposal.sponsorCode') }
  element(:prime_sponsor_code) { |b| b.text_field(name: 'document.developmentProposal.primeSponsorCode') }

end                                                                   