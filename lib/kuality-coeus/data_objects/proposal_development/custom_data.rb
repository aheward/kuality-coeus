class CustomDataObject

  include Foundry
  include DataFactory
  include Navigation
  include StringFactory
  include Utilities

  attr_accessor :document_id, :graduate_student_count, :billing_element, :doc_type

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        graduate_student_count: rand(50).to_s,
        billing_element:        random_alphanums(40)
    }
    set_options(defaults.merge(opts))
    requires :document_id, :doc_type
  end

  def create
    navigate
    on page_class do |create|
      create.expand_all
      fill_out create, :graduate_student_count, :billing_element
      create.save
    end
  end

  # =======
  private
  # =======

  # Nav Aids...

  def navigate
    open_document @doc_type
    on(Proposal).custom_data unless on_page?(on(page_class).asdf_tab)
  end

  def page_class
    Kernel.const_get({
                           kc_award_: 'AwardCustomData',
      proposal_development_document_: 'PDCustomData',
     institutional_proposal_document: 'IPCustomData'
                     }[snake_case(@doc_type)])
  end

end