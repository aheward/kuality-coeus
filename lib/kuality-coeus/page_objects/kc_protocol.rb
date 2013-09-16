class KCProtocol < BasePage

  document_header_elements
  tab_buttons
  global_buttons

  class << self

    def protocol_header_elements
      buttons 'Protocol', 'Personnel', 'Questionnaire', 'Custom Data', 'Special Review',
              'Permissions', 'Notes & Attachments', 'Protocol Actions', 'Medusa'
    end

  end

end