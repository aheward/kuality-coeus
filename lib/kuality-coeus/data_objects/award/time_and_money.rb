class TimeAndMoneyObject

  include Foundry
  include DataFactory

  attr_accessor :description

  def initialize(browser, opts={})
    @browser = browser

    defaults = {}
    set_options(defaults.merge(opts))
  end

  def create

  end

end