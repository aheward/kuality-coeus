class Unit < BasePage

  header_tabs

  action(:add_proposal_development) { |b| b.link(title: "Proposal Development", index: 0).click }

end