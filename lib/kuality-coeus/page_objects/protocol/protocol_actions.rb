class ProtocolActions < KCProtocol

  # Available Actions
  # Submit for Review
  element(:submit_for_review_div) { |b| b.frm.div(id: 'tab-:SubmitforReview-div') }
  element(:submission_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionTypeCode') }
  element(:submission_review_type) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.protocolReviewTypeCode') }
  element(:type_qualifier) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.submissionQualifierTypeCode') }
  element(:committee) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.committeeId') }
  element(:schedule_date) { |b| b.frm.select(name: 'actionHelper.protocolSubmitAction.scheduleId') }

  # Returns an array containing the names of the listed reviewers
  value(:reviewers) { |b|
                       # Note that this method works for both Submit for Review...
                       if b.reviewers_row.present?
                         b.reviewers_row.hiddens(name: /fullName/).map{|r| r.value}
                       else
                       # ...or for Assign Reviewers
                         b.assign_reviewers_div.selects(title: 'Reviewer Type').map{|s| s.parent.parent.td.text}
                       end
  }

  p_element(:reviewer_type) { |name, b| b.reviewers_container.td(text: name ).parent.select(name: /reviewerTypeCode/) }

  element(:reviewers_row) { |b| b.frm.tr(id: 'reviewers') }
  element(:expedited_review_checklist) { |b| b.frm.tr(id: 'expeditedReviewCheckList') }
  element(:exempt_studies_checklist) { |b| b.frm.tr(id: 'exemptStudiesCheckList') }

  action(:submit_for_review) { |b| b.frm.button(name: 'methodToCall.submitForReview.anchor:SubmitforReview').click; b.loading; b.awaiting_doc }

  # Assign Reviewers
  element(:assign_reviewers_div) { |b| b.frm.div(id: 'tab-:AssignReviewers-div') }
  action(:assign_reviewers) { |b| b.frm.button(name:'methodToCall.assignReviewers.anchor:AssignReviewers').click; b.loading }

  # Manage Review Comments
  p_element(:review_comment) { |text, b| b.frm.textarea(value: text) }
  p_element(:comment_private) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Private') }
  p_element(:comment_final) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Final') }
  action(:manage_comments) { |b| b.frm.button(name: /methodToCall.manageComments.anchor/).click; b.loading }

  # Withdraw Protocol
  element(:withdrawal_reason) { |b| b.frm.textarea(name: 'actionHelper.protocolWithdrawBean.reason') }
  action(:submit_withdrawal_reason) { |b| b.frm.button(name: 'methodToCall.withdrawProtocol.anchor:WithdrawProtocol').click; b.loading }

  # Summary & History
  value(:review_comments) { |b|
    begin
      b.review_comments_table.hiddens.map{ |hid| hid.value }
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      []
    end
  }


  private

  element(:reviewers_container) { |b|
    if b.reviewers_row.present?
      b.reviewers_row
    else
      b.assign_reviewers_div
    end
  }

  element(:review_comments_table) { |b| b.frm.div(id: 'tab-:ReviewComments-div').table }
  
end