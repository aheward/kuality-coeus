class CentralAdmin < BasePage

  page_url "#{$base_url}portal.do?selectedTab=portalCentralAdminBody"

  green_buttons create_award: 'Award', create_proposal_log: 'Proposal Log'

end