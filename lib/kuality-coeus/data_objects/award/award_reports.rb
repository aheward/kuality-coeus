class AwardReportsObject < DataFactory

  attr_reader :award_id, :report, :type, :frequency,
              :frequency_base, :osp_file_copy,
              :due_date, :recipients, :details,
              # :number is used for field identification in the list
              :number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      type:           '::random::',
      frequency:      '::random::',
      frequency_base: '::random::',
      osp_file_copy:  '::random::',
      details:        collection('ReportTracking')
      #recipients:    collection('ReportRecipients')

    }
    set_options(defaults.merge(opts))
    requires :award_id, :report, :number
  end

  def create
    on PaymentReportsTerms do |page|
      DEBUG.message "adding #{type} report to #{award_id}"
      page.expand_all
      page.refresh_selection_lists
      DEBUG.message 'refreshed'
      page.add_report_type(@report).pick! @type
      DEBUG.message 'set report type'
      page.add_report_type(@report).fire_event('onchange')
      page.add_frequency(@report).pick! @frequency
      DEBUG.message 'set frequency'
      page.add_frequency(@report).fire_event('onchange')
      page.add_frequency_base(@report).pick! @frequency_base
      DEBUG.message 'set frequency base'
      page.add_frequency_base(@report).fire_event('onchange')
      page.add_osp_file_copy(@report).pick! @osp_file_copy
      DEBUG.message 'set osp file copy'
      page.add_due_date(@report).fit @due_date
      page.add_report(@report)
      page.save
      DEBUG.message 'saved report'
    end
  end

end # AwardReportsObject

class AwardReportsCollection < CollectionFactory

  contains AwardReportsObject

  def count_of(report_class)
    self.count{ |r_obj| r_obj.report==report_class }
  end

end