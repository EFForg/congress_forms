module CongressForms
  class Form
    attr_accessor :bioguide, :actions
    attr_accessor :success_status, :success_content

    @@repo = nil

    def self.repo
      @@repo ||=
        Repo.new(CongressForms.contact_congress_remote).tap do |repo|
          repo.location = CongressForms.contact_congress_repository
          repo.auto_update = CongressForms.auto_update_contact_congress?
        end
    end

    def self.find(bioguide)
      if Cwc::Client.new.office_supported?(bioguide)
        CwcForm.new(bioguide)
      else
        parse(repo.find("members/#{bioguide}.yaml"))
      end

    rescue Errno::ENOENT => e
      nil
    end

    def self.parse(file)
      yaml = YAML.load_file(file)

      actions = yaml.dig("contact_form", "steps").map do |step|
        Actions.build(step)
      end.flatten

      new(
        actions,
        bioguide: yaml["bioguide"],
        success_status:
          yaml.dig("contact_form", "success", "headers", "status"),
        success_content:
          yaml.dig("contact_form", "success", "body", "contains")
      )
    end

    def self.create_browser
      Capybara::Session.new(:headless_chrome)
    end

    def initialize(actions = [], bioguide: nil,
                   success_status: nil,
                   success_content: nil)
      self.bioguide = bioguide
      self.actions = actions
      self.success_status = success_status
      self.success_content = success_content
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

    def fill(values, browser: self.class.create_browser, submit: true)
      actions.each do |action|
        break if action.submit? && !submit

        action.perform(browser, values)
      end
    rescue Capybara::CapybaraError => e
      raise Error, e.message
    end
  end
end
