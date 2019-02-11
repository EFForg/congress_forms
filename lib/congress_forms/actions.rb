module CongressForms
  module Actions
    DEFAULT_FIND_WAIT_TIME = 5

    def self.build(step)
      key = step.keys.first

      const_name = key.capitalize.gsub(/_(\w)/){ |m| m[1].upcase }
      klass = const_get(const_name, false)

      if Visit == klass
        Array(klass.new("value" => step[key]))
      else
        step[key].map do |params|
          klass.new(params)
        end
      end
    end

    class Base
      attr_accessor :selector, :value, :options, :required
      alias :required? :required

      def initialize(params = {})
        self.selector = params["selector"]
        self.value = params["value"]
        self.options = params["options"] || {}
        self.required = !!params["required"]
      end

      def max_length
        options.is_a?(Hash) ? options["max_length"] : nil
      end

      def select_options
        [Choose, Select].include?(self.class) ? options : nil
      end

      def placeholder_value?
        value[0, 1] == "$"
      end

      def escape_css_attribute(v)
        v.gsub('"', '\"')
      end

      def submit?
        "#{value} #{selector}".match(/submit/i)
      end

      def inspect
        s = "#{self.class.name.sub(/^CongressForms::Actions::/, '')}("
        s << "#{selector.inspect}, " unless selector.nil?
        s << value.inspect << ")"
      end
    end

    class Visit < Base
      def perform(browser, params={})
        browser.visit(value)
      end
    end

    class Wait < Base
      def perform(browser, params={})
        sleep(value.to_i)
      end
    end

    class FillIn < Base
      def perform(browser, params={})
        if placeholder_value?
          value = params.fetch(self.value).gsub("\t", "    ")

          maxl = options["max_length"]
          value = value[0, (0.95 * maxl).floor] if maxl
        else
          value = self.value
        end

        browser.find(selector).set(value)
      end
    end

    class Select < Base
      def perform(browser, params={})
        user_value = params[value]

        browser.within(selector) do
          if placeholder_value?
            option_value = user_value
          else
            option_value = value
          end

          begin
            elem = browser.first('option[value="' + escape_css_attribute(option_value) + '"]')
          rescue Capybara::ElementNotFound
            elem = browser.first('option', text: Regexp.compile("^" + Regexp.escape(option_value) + "(\\W|$)"))
          end

          elem.select_option
        end
      rescue Capybara::ElementNotFound => e
        raise e, e.message unless options == "DEPENDENT"
      end
    end

    class ClickOn < Base
      def perform(browser, params={})
        browser.find(selector).click
      end
    end

    class Find < Base
      def perform(browser, params={})
        wait_val = options["wait"] || DEFAULT_FIND_WAIT_TIME

        if value.nil?
          browser.find(selector, wait: wait_val)
        else
          browser.find(selector, text: Regexp.compile(value),
                                 wait: wait_val)
        end
      end
    end

    class Check < Base
      def perform(browser, params={})
        browser.find(selector).set(true)
      end
    end

    class Uncheck < Base
      def perform(browser, params={})
        browser.find(selector).set(false)
      end
    end

    class Choose < Base
      def perform(browser, params={})
        if options.any?
          user_value = params[value]

          browser.
            find(selector + '[value="' + escape_css_attribute(user_value) + '"]').
            set(true)
        else
          browser.find(selector).set(true)
        end
      end
    end

    class Javascript < Base
      def perform(browser, params={})
        browser.driver.evaluate_script(value)
      end
    end
  end
end
