class InstitutionalProposal < KCInstitutionalProposal

  inst_prop_header_elements
  description_field

  value(:institutional_proposal_number) { |b| b.institutional_proposal_tab.table[0][1].text }
  value(:status_ro) { |b| b.institutional_proposal_tab.table[2][3].text }
  element(:status) { |b| b.frm.select(name: 'document.institutionalProposal.statusCode') }
  element(:proposal_type) { |b| b.frm.select(name: 'document.institutionalProposalList[0].proposalTypeCode') }
  element(:activity_type) { |b| b.frm.select(name: 'document.institutionalProposalList[0].activityTypeCode') }
  element(:project_title) { |b| b.frm.text_field(name: 'document.institutionalProposalList[0].title') }
  element(:sponsor_id) { |b| b.frm.text_field(name: 'document.institutionalProposalList[0].sponsorCode') }

  # ===========
  private
  # ===========
  
  element(:document_overview_tab) { |b| b.frm.div(id: 'tab-DocumentOverview-div') }
  element(:institutional_proposal_tab) { |b| b.frm.div(id: 'tab-InstitutionalProposal-div') }
  element(:sponsor_program_info_tab) { |b| b.frm.div(id: 'tab-SponsorProgramInformation-div') }
  element(:financial_tab) { |b| b.frm.div(id: 'tab-Financial-div') }
  element(:graduate_students_tab) { |b| b.frm.div(id: 'tab-GraduateStudents-div') }
  element(:notes_and_attachments_tab) { |b| b.frm.div(id: 'tab-NotesandAttachments-div') }
  element(:delivery_info_tab) { |b| b.frm.div(id: 'tab-DeliveryInfo-div') }
  element(:keywords_tab) { |b| b.frm.div(id: 'tab-Keywords-div') }
  
end