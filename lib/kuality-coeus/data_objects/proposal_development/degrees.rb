class DegreeObject

  include Foundry
  include DataFactory
  include StringFactory

  attr_accessor :type, :description, :graduation_year, :school,
                :document_id, :person

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        type:            '::random::',
        description:     random_alphanums_plus,
        graduation_year: Time.random(year_range: 35).strftime('%Y')
    }
    set_options(defaults.merge(opts))
    requires :document_id, :person
  end

  def create
    # This method assumes navigation was performed by the parent object
    on KeyPersonnel do |degrees|
      degrees.expand_all
      degrees.degree_type(@person).pick! @type
      degrees.degree_description(@person).fit @description
      degrees.graduation_year(@person).fit @graduation_year
      degrees.school(@person).fit @school
      degrees.add_degree(@person)
    end
  end

end

class DegreesCollection < Array



end