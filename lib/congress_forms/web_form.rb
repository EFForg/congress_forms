module CongressForms
  class WebForm < Form
    attr_accessor :bioguide, :actions
    attr_accessor :success_status, :success_content
    attr_accessor :updated_at

    def self.parse(spec, attrs={})
      yaml = YAML.load(spec)

      actions = yaml.dig("contact_form", "steps").map do |step|
        Actions.build(step)
      end.flatten

      new(
        actions,
        attrs.merge(
          bioguide: yaml["bioguide"],
          success_status:
            yaml.dig("contact_form", "success", "headers", "status"),
          success_content:
            yaml.dig("contact_form", "success", "body", "contains"),
        )
      )
    end

    def self.create_browser
      if ENV["HEADLESS"] == "0"
        Capybara::Session.new(:chrome)
      elsif ENV["WEBDRIVER_HOST"] && !ENV["WEBDRIVER_HOST"].empty?
        Capybara::Session.new(:remote)
      else
        Capybara::Session.new(:headless_chrome)
      end.tap do |browser|
        browser.current_window.resize_to(1920, 1080)
      end
    end

    def initialize(actions = [], bioguide: nil,
                   success_status: nil,
                   success_content: nil,
                   updated_at: nil)
      self.bioguide = bioguide
      self.actions = actions
      self.success_status = success_status
      self.success_content = success_content
      self.updated_at = updated_at
    end

    def required_params
      required_actions = actions.dup

      required_actions.select!(&:required?)
      required_actions.select!(&:placeholder_value?)

      required_actions.map do |action|
        {
          value: action.value,
          max_length: action.max_length,
          options: action.select_options
        }
      end
    end

    def fill(values, browser: self.class.create_browser, validate_only: false)
      log("#{bioguide} fill")

      actions.each do |action|
        break if action.submit? && validate_only

        log(action.inspect)

        action.perform(browser, values)
      end

      log("done: success")
    rescue Capybara::CapybaraError, Selenium::WebDriver::Error::WebDriverError => e
      log("done: error")

      error = Error.new(e.message)
      error.set_backtrace(e.backtrace)

      attach_screenshot(browser, error)

      raise error
    ensure
      browser.driver.quit
    end

    protected

    def log(message)
      if defined?(Rails)
        Rails.logger.debug(message)
      end

      if defined?(Raven)
        unless Raven.context.extra.key?(:fill_log)
          Raven.extra_context(fill_log: "")
        end

        Raven.context.extra[:fill_log] << message << "\n"
      end
    end

    def attach_screenshot(browser, error)
      if dir = ENV["CONGRESS_FORMS_SCREENSHOT_LOCATION"]
        random = SecureRandom.hex(16)
        stamp = Time.now.strftime("%Y-%m-%d_%H:%M:%S")

        path = "#{dir}/#{bioguide}/#{stamp}_#{random}.png"
        FileUtils.mkdir_p(File.dirname(path))

        browser.save_screenshot(path, full: true)

        error.screenshot = path
      end
    rescue Selenium::WebDriver::Error::NoSuchDriverError => e
      nil
    end
  end
end
