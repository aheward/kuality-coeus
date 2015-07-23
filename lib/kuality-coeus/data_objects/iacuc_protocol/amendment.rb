class IACUCAmendmentObject < DataFactory

  include StringFactory, Utilities

  attr_reader :summary, :sections, :document_id, :amendment_number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        summary: random_alphanums_plus,
        sections: SECTIONS.shuffle[0..2]
    }

    set_options(defaults.merge(opts))
  end

  def create
    # Navigation currently in the Protocol object's #add_amendent method.
    on CreateAmendment do |page|
      page.expand_all
      page.summary.set @summary
      @sections.each do |sect|
        page.amend(sect).set
      end



      DEBUG.pause 9861



      page.create
    end
    confirmation
    on(NotificationEditor).send_it if on(NotificationEditor).send_button.present?
    on(CreateAmendment).save

    @amendment[:protocol_number] = @doc[:protocol_number]
    @amendment[:document_id] = @doc[:document_id]

    @document_id = on(IACUCProtocolActions).document_id

  end

  SECTIONS = ['General Info', 'Funding Source', 'Protocol References and Other Identifiers',
              'Protocol Organizations', 'Questionnaire', 'General Info',
              'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others']

end