# This is a collection class for UserObjects.
class Users < Array

  include Singleton

  def logged_in_user
    self.find { |user| user.session_status == 'logged in' }
  end
  alias_method :current_user, :logged_in_user

  def user(username)
    self.find { |user| user.user_name == username }
  end

  def type(type)
    self.find { |user| user.type == type }
  end

  def with_role_in_unit(role, unit)
    role_num = UserObject::ROLES[role]
    self.find { |user| !user.roles.nil? && user.roles.include?(role_num) && user.role_qualifiers[:"#{role_num}"]==unit }
  end

  def admin
    self.user('admin')
  end

end # Users

# This is a special collection class that inherits from Hash and contains
# the user information listed in the users.yml file.
class UserYamlCollection < Hash

  # Returns an array of all users with the specified role. Takes the role name as a string.
  # The array is shuffled so that #have_role('role name')[0] will be a random selection
  # from the list of matching users.
  def have_role(role)
    self.find_all{|user| user[1][:roles] != nil && user[1][:roles].include?(role)}.shuffle
  end

  # Returns an array of all users with the specified campus code. Takes the code as a string.
  # The array is shuffled so that #with_campus_code('code')[0] will be a random selection
  # from the list of matching users.
  def with_campus_code(code)
    self.find_all{|user| user[1][:campus_code]==code }.shuffle
  end

  # Returns an array of all users with the specified affiliation type. Takes the type name as a string.
  # The array is shuffled so that #with_affiliation_type('type name')[0] will be a random selection
  # from the list of matching users.
  def with_affiliation_type(type)
    self.find_all{|user| user[1][:affiliation_type]==type }.shuffle
  end

  def with_employee_type(type)
    self.find_all{|user| user[1][:employee_type]==type }.shuffle
  end

  def with_primary_dept_code(code)
    self.find_all{|user| user[1][:primary_dept_code]==code }.shuffle
  end

  def grants_gov_pi
    self.find_all { |user| !user[1][:primary_department_code].nil? &&
                           !user[1][:phones].find{|phone| phone[:type]=='Work'}.nil? &&
                           !user[1][:emails].find{|email| email[:type]=='Work'}.nil? &&
                           !user[1][:era_commons_user_name].nil?
    }.shuffle[0][0]
  end

end # UserYamlCollection

class UserObject

  include Foundry
  include DataFactory
  include Navigation
  include StringFactory

  attr_accessor :user_name, :principal_id,
                :first_name, :last_name,
                :description, :affiliation_type, :campus_code,
                :employee_id, :employee_status, :employee_type, :base_salary, :primary_department_code,
                :groups, :roles, :role_qualifiers, :addresses, :phones, :emails,
                :primary_title, :directory_title, :citizenship_type,
                :era_commons_user_name, :graduate_student_count, :billing_element,
                :directory_department,
                :session_status, :type

  USERS = UserYamlCollection[YAML.load_file("#{File.dirname(__FILE__)}/users.yml")]

  ROLES = {
      # Add roles here as needed for testing...
      'Aggregator'                      => '110',
      'approver'                        => '103',
      'Award Budget Aggregator'         => '113',
      'Award Budget Approver'           => '112',
      'Award Budget Modifier'           => '102',
      'Award Budget Viewer'             => '101',
      'Award Viewer'                    => '123',
      'Budget Creator'                  => '108',
      'Create Proposal Log'             => '140',
      'Departments Awards Viewer'       => '121',
      'IACUC Approver'                  => '1651',
      'IACUC Protocol Aggregator'       => '1421',
      'IACUC Protocol Approver'         => '1638',
      'Institutional Proposal Viewer'   => '118',
      'IRB Administrator'               => '128',
      'IRB Approver'                    => '99',
      'IRB Reviewer'                    => '127',
      'KC Super User'                   => '177',
      'Maintain IRB Questionnaire'      => '161',
      'Maintain Proposal Questionnaire' => '162',
      'Manager'                         =>  '98',
      'Narrative Writer'                => '109',
      'Negotiation Creator'             => '1382',
      'OSP Administrator'               => '131',
      'OSPApprover'                     => '100',
      'Proposal Creator'                => '111',
      'Protocol Aggregator'             => '105',
      'Protocol Approver'               => '149',
      'Protocol Creator'                => '129',
      'Protocol Viewer'                 => '104',
      'System User'                     => '90',
      'Unassigned'                      => '106',
      'Viewer'                          => '107',
      'View Subaward'                   => '1409',
      'View Proposal Log'               => '142'
  }

  def initialize(browser, opts={})
    @browser = browser

    defaults={
        user_name:        random_letters(16),
        description:      random_alphanums,
        affiliation_type: 'Student',
        campus_code:      'UN - UNIVERSITY',
        first_name:       random_alphanums,
        last_name:        random_alphanums,
        addresses:        [{ type:   'Work',
                            line_1:  '1375 N Scottsdale Rd',
                            city:    'scottsdale',
                            state:   'ARIZONA',
                            country: 'United States',
                            zip:     '85257',
                            default: :set }],
        phones:           [{ type:   'Work',
                            number:  '602-840-7300',
                            default: :set }],
        roles:           ['106'],
        role_qualifiers: { :"106"=> '000001' },
    }
    defaults.merge!(opts)

    @user_name=case
               when opts.empty?
                 'admin'
               when opts.key?(:user)
                 opts[:user]
               when opts.key?(:role)
                 USERS.have_role(ROLES[opts[:role]])[0][0]
               else
                 :not_nil
               end
    options = USERS[@user_name].nil? ? defaults : USERS[@user_name].merge(opts)

    set_options options
  end

  def create
    visit(SystemAdmin).person
    on(PersonLookup).create
    on Person do |add|
      add.expand_all
      add.principal_name.set @user_name
      fill_out add, :description, :affiliation_type, :campus_code, :first_name, :last_name
      # TODO: These "default" checkboxes will need to be reworked if and when
      # a test is going to require multiple affiliations, names, addresses, etc.
      # Until then, there's no need to do anything other than set the necessary single values
      # as "default"...
      add.affiliation_default.set
      add.name_default.set
      add.add_name
      add.add_affiliation
      # TODO: Another thing that will need to be changed if ever there's a need to test multiple
      # lines of employment:
      unless @employee_id.nil?
        fill_out add, :employee_id, :employee_status, :employee_type, :base_salary,
                 :primary_department_code
        add.primary_employment.set
        add.add_employment_information
      end
      unless @roles.nil?
        @roles.each do |role|
          add.role_id.set role
          add.add_role
        end
      end
      unless @role_qualifiers.nil?
        @role_qualifiers.each do |role, unit|
          add.unit_number(role).set unit
          add.add_role_qualifier role
        end
      end
      unless @groups.nil?
        @groups.each do |group|
          add.group_id.set group
          add.add_group
        end
      end
      unless @addresses.nil?
        @addresses.each do |address|
          add.address_type.fit address[:type]
          add.line_1.fit address[:line_1]
          add.city.fit address[:city]
          add.state.pick! address[:state]
          add.country.pick! address[:country]
          add.zip.fit address[:zip]
          add.address_default.fit address[:default]
          add.add_address
        end
      end
      unless @phones.nil?
        @phones.each do |phone|
          add.phone_type.fit phone[:type]
          add.phone_number.fit phone[:number]
          add.phone_default.fit phone[:default]
          add.add_phone
        end
      end
      unless @emails.nil?
        @emails.each do |email|
          add.email.fit email[:email]
          add.email_type.pick! email[:type]
          add.email_default.fit email[:default]
          add.add_email
        end
      end
      # A breaking of the design pattern, but there's no other
      # way to obtain this number:
      @principal_id = add.principal_id
      add.blanket_approve
    end

    unless extended_attributes.compact.length==0
      visit(SystemAdmin).person_extended_attributes
      on(PersonExtendedAttributesLookup).create
      on PersonExtendedAttributes do |page|
        page.expand_all
        fill_out page, :description, :primary_title, :directory_title, :citizenship_type,
                 :era_commons_user_name, :graduate_student_count, :billing_element,
                 :principal_id, :directory_department
        page.blanket_approve
      end
    end

  end # create

  # Keep in mind...
  # - If some other user is logged in, they
  #   will be automatically logged out
  # - This method will close all child
  #   tabs/windows and return to the
  #   original window
  def sign_in
    $users.logged_in_user.sign_out unless $users.current_user==nil
    # This line is required because visiting the login page doesn't
    # actually work when you're currently logged in.
    #s_o.click if s_o.present?
    visit Login do |log_in|
      log_in.username.set @user_name
      log_in.login
    end
    on(Researcher).logout_button.wait_until_present
    @session_status='logged in'
  end
  alias_method :log_in, :sign_in

  def sign_out
    visit(Login).close_extra_windows
    s_o.click if s_o.present?
    @session_status='logged out'
  end
  alias_method :log_out, :sign_out

  def exist?
    $users.admin.log_in if $users.current_user==nil
    visit(SystemAdmin).person
    on PersonLookup do |search|
      search.principal_name.set @user_name
      search.search
      begin
        if search.item_row(@user_name).present?
          # FIXME!
          # This is a coding abomination to include
          # this here, but it's here until I can come
          # up with a better solution...
          @principal_id = search.item_row(@user_name).link(title: /^Person Principal ID=\d+/).text
          return true
        else
          return false
        end
      rescue
        return false
      end
    end
  end
  alias_method :exists?, :exist?

  # TODO: This method needs a logic revamp in order to
  # ensure it does not enter an infinite loop.
  def logged_in?
    # Are we on the login page already?
    if username_field.present?
      # Yes! So, we're not logged in...
      false
    # No, the Kuali header is showing...
    elsif login_info_div.present?
      # So, is the user currently listed as logged in?
      return login_info_div.text.include? @user_name
    else # We're on some page that has no Kuali header, so...
      begin
        # We'll assume that the portal window exists, and go to it.
        on(BasePage).return_to_portal
      # Oops. Apparently there's no portal window, so...
      rescue
        # We'll close any extra tabs/windows
        on(BasePage).close_children if @browser.windows.size > 1
        # And make sure that we're using the "parent" window
        @browser.windows[0].use
      end
      # Now that things are hopefully in a clean state, we'll start
      # the process again...
      logged_in?
    end
  end

  def logged_out?
    !logged_in?
  end

  #========
  private
  #========

  def s_o
    @browser.button(value: 'Logout')
  end

  def login_info_div
    @browser.div(id: 'login-info')
  end

  def username_field
    Login.new(@browser).username
  end

  def extended_attributes
    [@primary_title, @directory_title, @citizenship_type,
     @era_commons_user_name, @graduate_student_count, @billing_element,
     @directory_department]
  end

end # UserObject

