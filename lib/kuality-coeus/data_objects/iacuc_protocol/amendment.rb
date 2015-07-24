class IACUCAmendmentObject < DataFactory

  include StringFactory, Utilities

  attr_reader :summary, :sections, :document_id, :amendment_number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        summary: random_alphanums_plus,
        sections: CreateAmendment::SECTIONS.shuffle[0..2]
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
      page.create
    end
    confirmation
    on(NotificationEditor).send_it if on(NotificationEditor).send_button.present?
    on IACUCProtocolActions do |page|
      @amendment_number = page.headerinfo_table.to_a


      DEBUG.inspect @amendment_number
      DEBUG.pause 5082

      @document_id = page.document_id
    end
  end

end