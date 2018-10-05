require "spec_helper"

describe CongressForms::WebForm do
  describe ".parse" do
    it "should build a Form from the yaml definition" do
      file, step, action = double, double, double
      yaml = {
        "bioguide" => double,
        "contact_form" => {
          "steps" => [step],
          "success" => {
            "headers" => { "status" => double },
            "body" => { "contains" => double }
          }
        }
      }

      expect(YAML).
        to receive(:load_file).with(file).and_return(yaml)
      expect(CongressForms::Actions).
        to receive(:build).with(step).and_return(action)
      expect(File).to receive(:mtime).with(file).and_return(Time.now)

      form = CongressForms::WebForm.parse(file)
      expect(form.bioguide).to eq(yaml["bioguide"])
      expect(form.actions).to eq([action])
      expect(form.success_status).
        to eq(yaml.dig("contact_form", "success", "headers", "status"))
      expect(form.success_content).
        to eq(yaml.dig("contact_form", "success", "body", "contains"))
    end
  end

  pending "#required_params"

  describe "#fill(values, browser:)" do
    it "should call #perform(browser, values) on each action" do
      values, browser = double, double
      actions = [double, double].map(&:as_null_object)
      expect(actions[0]).to receive(:perform).with(browser, values)
      expect(actions[1]).to receive(:perform).with(browser, values)
      CongressForms::WebForm.new(actions).fill(values, browser: browser)
    end
  end
end
