class ProposalActions < ProposalDevelopmentDocument

  proposal_header_elements
  route_log
  tiny_buttons
  validation_elements

  glbl 'Submit To Sponsor', 'Submit To S2S', 'Send AdHoc Requests'

  # Data Validation
  element(:data_validation_header) { |b| b.frm.h2(text: 'Data Validation') }
  element(:key_personnel_errors_button) { |b| b.frm.button(name: 'methodToCall.toggleTab.tabKeyPersonnelInformationValidationErrors') }
  action(:show_key_personnel_errors) { |b| b.key_personnel_button.click }
  element(:key_personnel_errors) { |b| b.frm.tbody(id: 'tab-KeyPersonnelInformationValidationErrors-div').tds(width: '94%') }
  action(:show_budget_versions_errors) { |b| b.frm.button(name: 'methodToCall.toggleTab.tabBudgetVersionsValidationErrors').click }
  action(:show_proposal_questions_errors) { |b| b.frm.button(name: 'methodToCall.toggleTab.tabAProposalQuestionsValidationErrors').click }
  element(:proposal_questions_errors) { |b| b.frm.tbody(id: 'tab-AProposalQuestionsValidationErrors-div').tds(width: '94%') }
  action(:show_kuali_u_errors) { |b| b.frm.button(name: 'methodToCall.toggleTab.tabCKualiUniversityValidationErrors').click }
  element(:kuali_u_errors) { |b| b.frm.tbody(id: 'tab-CKualiUniversityValidationErrors-div').tds(width: '94%') }
  action(:show_questionnaire_errors) { |b| b.frm.button(name: 'methodToCall.toggleTab.tabS2SFATFlatQuestionnaireValidationErrors').click }
  element(:questionnaire_errors) { |b| b.frm.tbody(id: 'tab-S2SFATFlatQuestionnaireValidationErrors-div').tds(width: '94%') }
  action(:show_compliance_errors) { |b| b.frm.button(name: 'methodToCall.toggleTab.tabBComplianceValidationErrors').click }
  element(:compliance_errors) { |b| b.frm.tbody(id: 'tab-BComplianceValidationErrors-div').tds(width: '94%') }

  action(:show_sponsor_warnings) { |b| b.frm.button(name: 'methodToCall.toggleTab.tabSponsorProgramInformationWarnings').click }
  element(:sponsor_warnings) { |b| b.frm.tbody(id: 'tab-SponsorProgramInformationWarnings-div').tds(width: '94%') }

  value(:warnings) { |b| b.frm.td(text: 'Warnings').parent.parent.td(class: 'datacell').text }
  value(:grants_gov_errors) { |b| b.frm.td(text: 'Grants.Gov Errors').parent.parent.td(class: 'datacell').text }
  value(:unit_business_rules_errors) { |b| b.frm.td(text: 'Unit Business Rules Errors').parent.parent.td(class: 'datacell').text }
  value(:unit_business_rules_warnings) { |b| b.frm.td(text: 'Unit Business Rules Warnings').parent.parent.td(class: 'datacell').text }

  element(:save_button) { |b| b.frm.button(name: 'methodToCall.save') }
  element(:approve_button) { |b| b.frm.button(name: 'methodToCall.approve') }
  element(:disapprove_button) { |b| b.frm.button(name: 'methodToCall.disapprove') }
  element(:reject_button) { |b| b.frm.button(name: 'methodToCall.reject') }

  # Proposal Hierarchy

  element(:link_child_proposal) { |b| b.frm.text_field(id: 'newHierarchyProposalNumber') }
  element(:link_budget_type) { |b| b.frm.select(id: 'newHierarchyBudgetTypeCode') }
  action(:link_to_hierarchy) { |b| b.frm.button(name: 'methodToCall.linkToHierarchy.anchorProposalHierarchy').click }

  # Ad Hoc Recipients

  element(:person_action_requested) { |b| b.frm.select(name: 'newAdHocRoutePerson.actionRequested') }
  element(:person) { |b| b.frm.text_field(name: 'newAdHocRoutePerson.id') }
  action(:add_person_request) { |b| b.frm.button(name: 'methodToCall.insertAdHocRoutePerson').click }

  element(:group_action_requested) { |b| b.frm.select(name: 'newAdHocRouteWorkgroup.actionRequested') }
  element(:namespace_code) { |b| b.frm.text_field(name: 'newAdHocRouteWorkgroup.recipientNamespaceCode') }
  element(:name) { |b| b.frm.text_field(name: 'newAdHocRouteWorkgroup.recipientName') }
  action(:add_group_request) { |b| b.frm.button(name: 'methodToCall.insertAdHocRouteWorkgroup').click }

  # =======
  private
  # =======

  #Notifications: People look up
  action(:employee_search) { |b| b.frm.button(name: /org.kuali.kra.bo.KcPerson/).click }

end