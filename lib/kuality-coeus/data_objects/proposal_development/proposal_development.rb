class ProposalDevelopmentObject < DataObject

  include StringFactory
  include DateFactory
  include Navigation
  include DocumentUtilities
  
  attr_accessor :proposal_type, :lead_unit, :activity_type, :project_title, :proposal_number,
                :sponsor_id, :sponsor_type_code, :project_start_date, :project_end_date, :document_id,
                :status, :initiator, :created, :sponsor_deadline_date, :key_personnel,
                :opportunity_id, # Maybe add competition_id and other stuff here...
                :special_review, :budget_versions, :permissions, :s2s_questionnaire, :proposal_attachments,
                :proposal_questions, :compliance_questions, :kuali_u_questions, :custom_data, :recall_reason,
                :personnel_attachments, :mail_by, :mail_type, :institutional_proposal_number, :nsf_science_code,
                :performance_site_locations

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      proposal_type:         'New',
      lead_unit:             '::random::',
      activity_type:         '::random::',
      project_title:         random_alphanums,
      sponsor_id:            '::random::',
      sponsor_type_code:     '::random::',
      nsf_science_code:      '::random::',
      project_start_date:    next_week[:date_w_slashes], # TODO: Think about using the date object here, and not the string
      project_end_date:      next_year[:date_w_slashes],
      sponsor_deadline_date: next_year[:date_w_slashes],
      mail_by:               '::random::',
      mail_type:             '::random::',
      performance_site_locations: [],
      key_personnel:         collection('KeyPersonnel'),
      special_review:        collection('SpecialReview'),
      budget_versions:       collection('BudgetVersions'),
      personnel_attachments: collection('PersonnelAttachments'),
      proposal_attachments:  collection('ProposalAttachments')
    }

    set_options(defaults.merge(opts))
  end
    
  def create
    visit(Researcher).create_proposal
    on Proposal do |doc|
      @doc_header=doc.doc_title
      @document_id=doc.document_id
      @status=doc.document_status
      @initiator=doc.initiator
      @created=doc.created
      doc.expand_all
      set_sponsor_code
      fill_out doc, :proposal_type, :activity_type,
                    :project_title, :project_start_date, :project_end_date,
                    :sponsor_deadline_date, :mail_by, :mail_type, :nsf_science_code
      set_lead_unit
      @performance_site_locations.each do |name|
        fill_out doc, :performance_site_locations
        doc.add_performance_site_locations
      end
      doc.save
      @proposal_number=doc.proposal_number
      @permissions = make PermissionsObject, document_id: @document_id, aggregators: [@initiator]
    end
  end

  def edit opts={}
    open_proposal
    on Proposal do |edit|
      edit.proposal
      edit.expand_all
      edit_fields opts, edit, :project_title, :project_start_date, :opportunity_id, :proposal_type
      # TODO: Add more stuff here as necessary
      edit.save
    end
    update_options(opts)
  end

  def add_per_sit_loc(name)
    on Prolpaps
    @performance_site_locations << name
  end

  def add_key_person opts={}
    @key_personnel.add merge_settings(opts)
  end
  # This alias is recommended only for when
  # using this method with no options.
  alias_method :add_principal_investigator, :add_key_person

  def add_special_review opts={}
    @special_review.add merge_settings(opts)
  end

  def add_budget_version opts={}
    opts[:version] ||= (@budget_versions.size+1).to_s
    @budget_versions.add merge_settings(opts)
  end

  def add_custom_data opts={}
    @custom_data = prep(CustomDataObject, opts)
  end

  def add_proposal_attachment opts={}
    @proposal_attachments.add merge_settings(opts)
  end

  def add_personnel_attachment opts={}
    @personnel_attachments.add merge_settings(opts)
  end

  def complete_s2s_questionnaire opts={}
    @s2s_questionnaire = prep(S2SQuestionnaireObject, opts)
  end

  def complete_phs_fellowship_questionnaire opts={}
    @phs_fellowship_questionnaire = prep(PHSFellowshipQuestionnaireObject, opts)
  end

  def complete_phs_training_questionnaire opts={}
    @phs_training_questionnaire = prep(PHSTrainingQuestionnaireObject, opts)
  end

  def make_institutional_proposal
    # TODO: Write any preparatory web site functional steps and page scraping code
    visit(Researcher).search_institutional_proposals
    on InstitutionalProposalLookup do |look|
      fill_out look, :institutional_proposal_number
      look.search
      look.open @institutional_proposal_number
    end
    doc_id = on(InstitutionalProposal).document_id
    ip = make InstitutionalProposalObject, dev_proposal_number: @proposal_number,
         proposal_type: @proposal_type,
         activity_type: @activity_type,
         project_title: @project_title,
         special_review: @special_review.copy,
         custom_data: @custom_data.data_object_copy,
         document_id: doc_id,
         proposal_number: @institutional_proposal_number,
         nsf_science_code: @nsf_science_code,
         sponsor_id: @sponsor_id
    @key_personnel.each do |person|
      project_person = make ProjectPersonnelObject, full_name: person.full_name,
                            first_name: person.first_name, last_name: person.last_name,
                            lead_unit: person.home_unit, role: person.role,
                            project_role: person.key_person_role, units: person.units,
                            responsibility: person.responsibility, space: person.space,
                            financial: person.financial, recognition: person.recognition,
                            document_id: doc_id
      ip.project_personnel << project_person
    end
    ip
  end

  def delete
    view 'Proposal Actions'
    on(ProposalActions).delete_proposal
    on(Confirmation).yes
    # Have to update the data object's status value
    # in a valid way (getting it from the system)
    visit DocumentSearch do |search|
      search.document_id.set @document_id
      search.search
      @status=search.doc_status @document_id
    end
  end

  def recall(reason=random_alphanums)
    @recall_reason=reason
    open_proposal
    on(Proposal).recall
    on Confirmation do |conf|
      conf.reason.set @recall_reason
      conf.yes
    end
    open_proposal
    @status=on(Proposal).document_status
  end

  def reject
    # TODO - Coeus is buggy right now
  end

  def close
    open_proposal
    on(Proposal).close
  end

  def view(tab)
    open_proposal
    unless @status=='CANCELED' || on(Proposal).send(StringFactory.damballa("#{tab}_button")).parent.class_name=~/tabcurrent$/
      on(Proposal).send(StringFactory.damballa(tab.to_s))
    end
  end

  def submit(type=:s)
    types={:s=>:submit, :ba=>:blanket_approve,
           :to_sponsor=>:submit_to_sponsor, :to_s2s=>:submit_to_s2s}
    view 'Proposal Actions'
    on(ProposalActions).send(types[type])
    if type==:to_sponsor
      on NotificationEditor do |page|
        # A breaking of the design pattern, here,
        # but we have no alternative...
        @status=page.document_status
        @institutional_proposal_number=page.institutional_proposal_number
        page.send_fyi
      end
    elsif type == :to_s2s
      view :s2s
      on S2S do |page|
        @status=page.document_status
      end
    else
      on ProposalActions do |page|
        page.data_validation_header.wait_until_present
        @status=page.document_status
      end
    end
  end

  # Note: This method does not navigate because
  # the assumption is that the only time you need
  # to save the proposal is when you are on the
  # proposal. You will never need to open the
  # proposal and then immediately save it.
  def save
    on(Proposal).save
  end

  def blanket_approve
    submit :ba
  end

  def approve
    on(ProposalSummary).approve
  end

  alias :sponsor_code :sponsor_id

  # =======
  private
  # =======

  # Step defs should use #view!
  def open_proposal
    open_document @doc_header
  end

  def merge_settings(opts)
    defaults = {
        document_id: @document_id,
        doc_type: @doc_header
    }
    opts.merge!(defaults)
  end

  def set_lead_unit
    on(Proposal)do |prop|
      if prop.lead_unit.present?
        prop.lead_unit.pick! @lead_unit
      else
        @lead_unit=prop.lead_unit_ro
      end
    end
  end

  def prep(object_class, opts)
    merge_settings(opts)
    object = make object_class, opts
    object.create
    object
  end

  def page_class
    Proposal
  end

end