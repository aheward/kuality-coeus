When /^(the (.*) user |)creates a Budget Version for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
end

When /a Budget Version is created for the Proposal$/ do
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
end

When /^I add a subaward budget to the Budget Version$/ do
  @budget_version.add_subaward_budget
end

Given /^(the (.*) user |)creates a final and complete Budget Version for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text ==''
  @proposal.add_budget_version status: 'Complete', final: :set
end

When /^I? ?copy the Budget Version \(all periods\)$/ do
  @copied_budget_version = @budget_version.copy_all_periods random_alphanums
end

When /^I? ?enter dollar amounts for all the budget periods$/ do
  @budget_version.budget_periods.each do |p|
    randomized_values = {}
    p.dollar_fields[1..-1].each { |f| randomized_values.store(f, random_dollar_value(500000)) }
    p.edit randomized_values
  end
end

Then /^the copied budget's values are all as expected$/ do
  @copied_budget_version.view 'Periods And Totals'
  @copied_budget_version.budget_periods.each do |period|
    n = period.number
    on PeriodsAndTotals do |page|
      expect(page.start_date_of(n).value).to eq period.start_date
      expect(page.end_date_of(n).value).to eq period.end_date
      expect(page.total_sponsor_cost_of(n).value.groom).to eq (period.direct_cost.to_f+period.f_and_a_cost.to_f).round(2)
      expect(page.direct_cost_of(n).value.groom).to eq period.direct_cost.groom
      expect(page.f_and_a_cost_of(n).value.groom).to eq period.f_and_a_cost.groom
      expect(page.unrecovered_f_and_a_of(n).value.groom).to eq period.unrecovered_f_and_a.groom
      expect(page.cost_sharing_of(n).value.groom).to eq period.cost_sharing.groom
      expect(page.cost_limit_of(n).value.groom).to eq period.cost_limit.groom
      expect(page.direct_cost_limit_of(n).value.groom).to eq period.direct_cost_limit.groom
    end
  end
end

When /deletes? one of the budget periods$/ do
  @budget_version.delete_period(rand(@budget_version.budget_periods.size)+1)
end

When /^I? ?changes? the date range for one of the periods$/ do
  period = @budget_version.budget_periods.sample
  new_start_date = '03'+period.start_date[/\/\d+\/\d+$/]
  new_end_date = '10'+period.end_date[/\/\d+\/\d+$/]
  period.edit start_date: new_start_date, end_date: new_end_date
end

When /the Budget Version's periods are reset to defaults$/ do
  @original_period_count = @budget_version.budget_periods.count
  @budget_version.reset_to_period_defaults
end

Then /^all budget periods get recreated, zeroed, and given default date ranges$/ do
  default_start_dates={1=>@proposal.project_start_date}
  default_end_dates={@years=>@proposal.project_end_date}
  1.upto(@years-1) do |i|
    default_start_dates.store(i+1, "01/01/#{@proposal.project_start_date[/\d+$/].to_i+i}")
    default_end_dates.store(@years-i, "12/31/#{@proposal.project_end_date[/\d+$/].to_i-i}")
  end
  on PeriodsAndTotals do |page|
    expect(page.period_count).to eq @years
    1.upto(@years) do |x|
      expect(page.start_date_of(x).value).to eq default_start_dates[x]
      expect(page.end_date_of(x).value).to eq default_end_dates[x]
      expect(page.total_sponsor_cost_of(x).value).to eq '0.00'
      expect(page.direct_cost_of(x).value).to eq '0.00'
      expect(page.f_and_a_cost_of(x).value).to eq '0.00'
      expect(page.unrecovered_f_and_a_of(x).value).to eq '0.00'
      expect(page.cost_sharing_of(x).value).to eq '0.00'
      expect(page.cost_limit_of(x).value).to eq '0.00'
      expect(page.direct_cost_limit_of(x).value).to eq '0.00'
    end
  end
end

When /includes the Budget Version for submission$/ do
  @budget_version.include_for_submission
end

When /marks? the Budget Version complete$/ do
  @budget_version.complete
end

When /^(the (.*) user |)creates a Budget Version with cost sharing for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
  @budget_version.edit_period(1, cost_sharing: random_dollar_value(1000000))
  @budget_version.period(1).cost_sharing_distribution_list.each do |cs|
    cs.edit source_account: random_alphanums
  end
end

And /^(the (.*) user |)creates a Budget Version with unrecovered F&A for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
  steps %q{ * add unrecovered F&A to the first period of the Budget Version }
end

And /adds? unrecovered F&A to the first period of the Budget Version$/ do
  total_allocated = random_dollar_value(1000000).to_f
  first_amount = (total_allocated/4).round(2)
  amounts = [ first_amount.to_s, (total_allocated - first_amount).round(2).to_s ]
  @budget_version.edit_period(1, unrecovered_f_and_a: total_allocated)
  @budget_version.period(1).unrecovered_fa_dist_list.each_with_index do |ufna, index|
    ufna.edit source_account: random_alphanums, amount: amounts[index]
  end
end

And /^adds another item to the budget period's cost sharing distribution list$/ do
  @budget_version.budget_periods.period(1).add_item_to_cost_sharing_dl
end

And /^adds (\d+) more items to the budget period's cost sharing distribution list$/ do |count|
  count.to_i.times do
    steps %{ * adds another item to the budget period's cost sharing distribution list }
  end
end

And /^adjusts the budget period's cost sharing amount so all funds are allocated$/ do
  @budget_version.period(1).edit cost_sharing: @budget_version.budget_periods.period(1).cost_sharing_distribution_list.total_funds.to_s
end

Then /^the Budget Version is no longer editable$/ do
  on(Header).researcher
  on(ResearcherMenu).search_proposals
  @budget_version.view 'Periods And Totals'
  on PeriodsAndTotals do |page|
    expect(page.add_budget_period_element).not_to be_present
  end
  # TODO: Add more validations here
end

Then /the Budget Version should have two more budget periods/ do
  expect(@budget_version.budget_periods.count).to eq @original_period_count+2
end

Then /^the copied budget is not marked 'for submission'$/ do
  on(PeriodsAndTotals).budget_versions
  expect(on(BudgetsDialog).submission_message(@copied_budget_version.name)).not_to be_visible
end

And /^the Budget Version is opened$/ do
  @proposal.view 'Budget'
  on(Budgets).open @budget_version.name
end

And /^auto-calculates the budget periods$/ do
  @budget_version.autocalculate_periods
end

And /adds a (direct|total) cost limit to all of the Budget's periods$/ do |type|
  cls = {direct: :direct_cost_limit, total: :cost_limit }
  @budget_version.budget_periods.each do |period|
    period.edit cls[type.to_sym] => random_dollar_value(50000)
  end
end

And /adds a (direct|total) cost limit of \$(\d+) to all of the Budget's periods$/ do |type, amount|
  cls = {direct: :direct_cost_limit, total: :cost_limit }
  @budget_version.budget_periods.each do |period|
    period.edit cls[type.to_sym] => amount
  end
end

Then /^the direct cost is equal to the direct cost limit in all periods$/ do
  @budget_version.view 'Periods And Totals'
  @budget_version.budget_periods.each do |period|
    on PeriodsAndTotals do |page|
      expect(page.direct_cost_of(period.number).groom).to eq period.direct_cost_limit.groom
    end
  end
end

Then /^the Budget's Periods & Totals should be as expected$/ do
  @budget_version.view 'Periods And Totals'
  @budget_version.budget_periods.each { |period|
    on PeriodsAndTotals do |page|
      # TODO: Add more checks of values here...
      expect(page.direct_cost_of(period.number).groom).to be_within(0.05).of period.direct_cost
      expect(page.f_and_a_cost_of(period.number).groom).to be_within(0.05).of period.f_and_a_cost
    end
  }
end

Then /^the Period's total sponsor cost should equal the cost limit$/ do
  @budget_version.view 'Periods And Totals'
  on PeriodsAndTotals do |page|
    1.upto(page.period_count) do |x|
      expect(page.cost_limit_of(x).value).to eq page.total_sponsor_cost_of(x)
    end
  end
end

And /^the Budget's unrecovered F&A amounts are as expected for all periods$/ do
  @budget_version.view :periods_and_totals
  @budget_version.budget_periods.each { |period|
    expect(on(PeriodsAndTotals).unrecovered_f_and_a_of(period.number).groom).to be_within(0.05).of period.unrecovered_f_and_a
  }
end


And /^syncs the modular budget$/ do
  @budget_version.view 'Modular'
  on(ModularBudget).sync
  on(SyncModularBudget).ok

  DEBUG.inspect @budget_version.budget_periods[0].non_personnel_costs[0].modular_f_and_a
  DEBUG.inspect @budget_version.budget_periods[0].non_personnel_costs[0].modular_f_a_base
  #DEBUG.inspect @budget_version.budget_periods[0].assigned_personnel.f_and_a[:cost]

  x = @budget_version.budget_periods[0].non_personnel_costs.direct

  DEBUG.inspect x

  y = (x/25000).ceil*25000

  DEBUG.inspect y

  #DEBUG.inspect @budget_version.budget_periods[0].assigned_personnel.direct_costs[:cost]


end