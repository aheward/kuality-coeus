class BudgetVersionsObject

  include Foundry
  include DataFactory
  include StringFactory
  include Navigation

  attr_accessor :name, :document_id, :status,
                # Stuff on Budget Versions page...
                :version, :direct_cost, :f_and_a, :on_off_campus,
                :total, :final, :residual_funds, :cost_sharing, :unrecovered_fa,
                :comments, :f_and_a_rate_type, :last_updated, :last_updated_by,
                # Stuff on the Parameters page...
                :project_start_date, :project_end_date, :total_direct_cost_limit,
                :budget_periods, :unrecovered_fa_rate_type, :f_and_a_rate_type,
                :submit_cost_sharing, :residual_funds, :total_cost_limit


  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      name:              random_alphanums_plus(40),
      cost_sharing:      '0.00',
      f_and_a:           '0.00',
      budget_periods:    BudgetPeriodsCollection.new
    }

    set_options(defaults.merge(opts))
    requires :document_id, :doc_type
  end

  def create
    navigate
    on BudgetVersions do |add|
      @doc_header=add.doc_title
      add.name.set @name
      add.add
      add.final(@name).fit @final
      add.budget_status(@name).pick! @status
      add.save
      break if parameters.compact==nil # No reason to continue if there aren't other things to do
      # Otherwise, go to parameters page and fill out the rest of the stuff...
      add.open(@name)
    end
    #TODO: This needs to be dealt with more intelligently.
    # It's clear that we need to learn more about how to set up
    # sponsors better, so that we can predict when this dialog
    # will show up and when it won't...
    confirmation
    on Parameters do |parameters|
      @project_start_date=parameters.project_start_date
      @project_end_date=parameters.project_end_date
      parameters.total_direct_cost_limit.fit @total_direct_cost_limit
      fill_out parameters, :comments, :modular_budget,
               :residual_funds, :total_cost_limit, :unrecovered_fa_rate_type,
               :f_and_a_rate_type, :submit_cost_sharing
      parameters.on_off_campus.fit @on_off_campus
      parameters.alert.ok if parameters.alert.exists?
      parameters.save
    end
    confirmation
    get_budget_periods
  end

  def add_period opts={}
    defaults={
        document_id: @document_id,
        budget_name: @name,
        doc_type: @doc_header
    }
    opts.merge!(defaults)

    bp = create BudgetPeriodObject, opts
    return if on(Parameters).errors.size > 0 # No need to continue the method if we have an error
    @budget_periods << bp
    @budget_periods.number! # This updates the number value of all periods, as necessary
  end

  def edit_period number, opts={}
    @budget_periods.period(number).edit opts
    @budget_periods.number!
  end

  def delete_period number
    @budget_periods.period(number).delete
    @budget_periods.delete(@budget_periods.period(number))
    @budget_periods.number!
  end

  # Please note, this method is for VERY basic editing...
  # Use it for editing the Budget Version while on the Proposal, but not the Periods
  def edit opts={}
    navigate
    on BudgetVersions do |edit|
      edit.final(@name).fit opts[:final]
      edit.budget_status(@name).fit opts[:budget_status]
      # TODO: More here as needed...
      edit.save
    end
    set_options(opts)
  end

  def open_budget
    navigate
    on BudgetVersions do |page|
      page.open @name
    end
    #TODO: This needs to be dealt with more intelligently.
    # It's clear that we need to learn more about how to set up
    # sponsors better, so that we can predict when this dialog
    # will show up and when it won't...
    confirmation
  end

  def copy_all_periods(new_name)
    navigate
    new_version_number='x'
    on(BudgetVersions).copy @name
    on(Confirmation).copy_all_periods
    on BudgetVersions do |copy|
      copy.name_of_copy.set new_name
      copy.save
      new_version_number=copy.version(new_name)
    end
    new_bv = self.clone
    new_bv.name=new_name
    new_bv.version=new_version_number
    new_bv
  end

  def copy_one_period(new_name, version)
    # pending resolution of a bug
  end

  def default_periods
    open_budget
    on Parameters do |page|
      page.parameters unless page.parameters_button.parent.class_name=='tabright tabcurrent'
      page.default_periods
    end
    @budget_periods.clear
    get_budget_periods
  end

  # =======
  private
  # =======

  # This is just a collection of the instance variables
  # associated with the Parameters page. It's used to determine
  # whether or not the create method should go to that page
  # and fill stuff out.
  def parameters
    [@total_direct_cost_limit, @on_off_campus, @comments, @modular_budget,
     @residual_funds, @total_cost_limit, @unrecovered_fa_rate_type, @f_and_a_rate_type,
     @submit_cost_sharing]
  end

  def get_budget_periods
    on Parameters do |page|
      1.upto(page.period_count) do |number|
        period = make BudgetPeriodObject, document_id: @document_id,
                      budget_name: @name, start_date: page.start_date_period(number).value,
                      end_date: page.end_date_period(number).value,
                      total_sponsor_cost: page.total_sponsor_cost_period(number).value.groom,
                      direct_cost: page.direct_cost_period(number).value.groom,
                      f_and_a_cost: page.fa_cost_period(number).value.groom,
                      unrecovered_f_and_a: page.unrecovered_fa_period(number).value.groom,
                      cost_sharing: page.cost_sharing_period(number).value.groom,
                      cost_limit: page.cost_limit_period(number).value.groom,
                      direct_cost_limit: page.direct_cost_limit_period(number).value.groom
        @budget_periods << period
      end
    end
    @budget_periods.number!
  end

  # Nav Aids...

  def navigate
    @doc_header ||= @doc_type
    open_document @doc_header
    on(Proposal).budget_versions unless on_page?(on(BudgetVersions).name)
  end

  # Use this if the confirmation dialog may appear
  # due to missing rates...
  def confirmation
    begin
      on(Confirmation) do |conf|
        conf.yes if conf.yes_button.present?
      end
    rescue
      # do nothing because the dialog isn't there
    end
  end

end # BudgetVersionsObject

class BudgetVersionsCollection < Array

  def budget(name)
    self.find { |budget| budget.name==name }
  end

  def copy_all_periods(name, new_name)
    self << self.budget(name).copy_all_periods(new_name)
  end

end # BudgetVersionsCollection