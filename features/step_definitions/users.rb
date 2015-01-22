# We need this step def because of the special case of
# the admin user. Its data object is already created
# and added to the Users collection at the start of the
# scripts.
Given /^I'm( signed)? in (as|with) the admin$/ do |x, y|
  $users.admin.sign_in
end

# Note the difference between the following three
# step definitions...

# This step definition is a bit dangerous
# 1) Assumes that the user already exists in the system
# 2) Assumes the user object does not exist, so it creates it, sticking it into
#    a class instance variable based on the username
# 3) Logs that user in (if they're not already)...
Given /^I'm logged in with (.*)$/ do |username|
  user = make_user(user: username)
  user.sign_in
end

# Whereas, this step def
# 1) Assumes the user OBJECT already exists
# 2) Assumes that role user already exists in the system
# 3) Logs that user in, if they're not already
Given /^I? ?log in (?:again)? ?with the (.*) user$/ do |role|
  user = $users.with_role(role)
  user.sign_in
end

# This step definition
# 1) Creates the user object in a class instance variable based on the user name
# 2) Creates the user in the system if they don't exist already,
#    by first logging in with the admin user
Given /^a User exists with the user name (.*)$/ do |username|
  if $users.user(username).nil?
    user = make_user user: username
    user.create unless user.exists?
  end
end

# This step definition will return a user with
# the specified role. If there are multiple matching
# users, it will select one of them randomly, and create
# them if they don't exist in the system (again by first
# logging in with the admin user to do the creation).
Given /^a User exists with the role: '(.*)'$/ do |role|
  if $users.with_role(role).nil?
    user = make_user role: role
    user.create unless user.exists?
  end
end

# This step definition will return a user with
# the specified role for the specified unit. If there
# are multiple matching users, it will select one
# of them randomly, and create them if they don't exist in the system (again by first
# logging in with the admin user to do the creation).
Given /^a User exists with the role '(.*)' in unit '(.*)'$/ do |role, unit|
  if $users.with_role_in_unit(role, unit).nil?
    user = make_user role: role, unit: unit
    user.create unless user.exists?
  end
end

# This step definition will return a user with
# the specified role for the specified unit. The role
# will descend the heirarchy. If there
# are multiple matching users, it will select one
# of them randomly, and create them if they don't exist in the system (again by first
# logging in with the admin user to do the creation).
Given /^a User exists with the role '(.*)' in unit '(.*)' \(descends hierarchy\)$/ do |role, unit|
  user_name = UserObject::USERS.have_hierarchical_role_in_unit(role, unit, :set)[0][0]
  # Be careful with this, as test cases with multiple users with the same role will cause
  # instance variable collision...
  $users << set(role, (make UserObject, user: user_name))
  $users[-1].create unless $users[-1].exists?
end

# Use this step definition immediately after a step where you
# have made/created a user. They'll be last in the collection.
# This is a dangerous step definition if your scenario is at all complicated.
And /^I log in with that User$/ do
  $users[-1].sign_in
end

Then /^(.*) is logged in$/ do |username|
  get(username).logged_in?.should be true
end

# TODO: This will need to be changed to add "in the same unit" as a qualifier
Given /^Users exist with the following roles: (.*)$/ do |roles|
  roles.split(', ').each do |r|
    if $users.with_role(r).nil?
      user = make_user role: r
      user.create unless user.exists?
    end
  end
end

Given /^a User exists that can be a PI for Grants.gov proposals$/ do
  make_user(user: UserObject::USERS.grants_gov_pi, type: 'Grants.gov PI')
  $users[-1].create unless $users[-1].exists?
end

Given /^a User exists with a '(.*)' appointment type$/ do |type|
  make_user(user: UserObject::USERS.with_appointment_type(type), type: type)
  $users[-1].create unless $users[-1].exists?
end

Given /^an AOR User exists$/ do
  # TODO: Using the username here is cheating. Fix this.
  @aor = make_user(user: 'warrens', type: 'AOR')
  @aor.create unless @aor.exists?
end

When /^I? ?create an? '(.*)' User$/ do |type|
  $users << create(UserObject, type: type)
end

Given /^I? ?create a User with an? (.*) role in the (.*) unit$/ do |role, unit|
  role_num = RoleObject::ROLES[role]
  $users << create(UserObject, rolez: [{ id: role_num, name: role, qualifiers: [{:unit=>unit}] }] )
end

Given /^I? ?log in (?:again)? ?as the User with the (.*) role in (.*)$/ do |role, unit|
  $users.with_role_in_unit(role, unit).sign_in
end

And /^I add the (.*) role in the (.*) unit to that User$/ do |role, unit|
  role_num = RoleObject::ROLES[role]
  $users[-1].add_role id: role_num, name: role, qualifiers: [{:unit=>unit}], user_name: $users[-1].user_name
end

# Use this step def when you know the role doesn't take a qualifier
And /^I add the (.*) role to that User$/ do |role|
  role_num = RoleObject::ROLES[role]
  $users[-1].add_role id: role_num, name: role, qualifiers: [], user_name: $users[-1].user_name
end

When /^a User exists with the roles: (.*) in the (.*) unit$/ do |roles, unit|
  users = []
  roles.split(', ').each do |role|
    users << UserObject::USERS.have_role_in_unit(role, unit)
  end
  raise 'There are no matching users in the users.yml file. Please add one.' if users.empty?
  user_name = users.inject(:&).shuffle[0][0]
  if $users.user(user_name).nil?
    make_user user: user_name
    $users[-1].create unless $users[-1].exists?
  end
end