class MemberRolesObject

  include Foundry
  include DataFactory
  include StringFactory

  attr_accessor :document_id, :name, :role, :start_date, :end_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {

    }

    set_options(defaults.merge(opts))
    requires :name, :document_id
  end

  def create

  end

end # MemberRolesObject

class MemberRolesCollection < Array

end # MemberRolesCollection