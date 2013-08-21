class IPReviewObject

  include Foundry
  include DataFactory
  include StringFactory
  include DateFactory
  include Navigation

  attr_accessor :document_id, :activities, :submitted_for_review, :reviewer

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        reviewer: '::random::',
        submitted_for_review: right_now, # Note: this is the date hash, not the string with slashes
        activities: [{number: '1', type_code: '::random::'}]
    }
    set_options(defaults.merge(opts))
    requires :document_id
  end

  # This method only "saves" the IPReview.
  # You must submit or blanket approve it before it actually does anything useful
  def create
    # TODO: Add helper navigation method(s) here
    on IPReview do |page|
      page.description.set random_alphanums # Note: The description field on this page is required, but seems irrelevant to anything important, at least at the moment
      page.submitted_for_review.set @submitted_for_review[:date_w_slashes]
      @activities.each do |activity|
        page.activity_number.set activity[:number]
        page.ip_review_activity_type_code.pick! activity[:type_code]
        # TODO: Obviously add more here as needed
      end
    end
    set_reviewer
    on(IPReview).save
  end

  def submit
    on(IPReview).submit
  end

  # ==========
  private
  # ==========

  def set_reviewer
    if @reviewer=='::random::'
      on(IPReview).find_reviewer
      on PersonLookup do |search|
        search.search
        search.return_random
      end
      @reviewer=on(IPReview).reviewer.value
    else
      on(IPReview).reviewer.fit @reviewer
    end
  end

  # TODO: Add navigational and other helper methods

end