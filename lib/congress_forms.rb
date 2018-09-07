require "yaml"

require "capybara"
require "selenium/webdriver"

require "congress_forms/version"

require "cwc"

Capybara.register_driver :chrome do
  Capybara::Selenium::Driver.new(nil, browser: :chrome)
end

Capybara.register_driver :headless_chrome do
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
      args: %w(headless no-sandbox disable-gpu window-size=1200,1400)
    }
  )

  Capybara::Selenium::Driver.new(
    nil,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

module CongressForms
  Error = Class.new(Exception)

  autoload :Form, "congress_forms/form"
  autoload :CwcForm, "congress_forms/cwc_form"
  autoload :Actions, "congress_forms/actions"

  autoload :Repo, "congress_forms/repo"

  @@contact_congress_remote = "https://github.com/unitedstates/contact-congress.git"


  def self.contact_congress_remote=(location)
    @@contact_congress_remote = location
  end

  def self.contact_congress_remote
    @@contact_congress_remote
  end

  @@contact_congress_repository = nil

  def self.contact_congress_repository=(location)
    @@contact_congress_repository = location
  end

  def self.contact_congress_repository
    @@contact_congress_repository
  end

  @@auto_update_contact_congress = true

  def self.auto_update_contact_congress=(auto_update)
    @@auto_update_contact_congress = auto_update
  end

  def self.auto_update_contact_congress?
    @@auto_update_contact_congress
  end
end
