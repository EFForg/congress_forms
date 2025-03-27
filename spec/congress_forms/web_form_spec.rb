require "spec_helper"

describe CongressForms::WebForm do
  describe ".parse" do
    it "should build a Form from the yaml definition" do
      spec, step, action = double, double, double

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
        to receive(:load).with(spec).and_return(yaml)

      expect(CongressForms::Actions).
        to receive(:build).with(step).and_return(action)

      timestamp = double

      form = CongressForms::WebForm.parse(spec, updated_at: timestamp)

      expect(form.bioguide).to eq(yaml["bioguide"])
      expect(form.actions).to eq([action])
      expect(form.success_status).
        to eq(yaml.dig("contact_form", "success", "headers", "status"))
      expect(form.success_content).
        to eq(yaml.dig("contact_form", "success", "body", "contains"))
      expect(form.updated_at).to eq(timestamp)
    end
  end

  pending "#required_params"

  describe "#fill(values, browser:)" do
    it "should call #perform(browser, values) on each action" do
      values, browser = double('values'), double('browser', quit: true)
      actions = [double('action 1'), double('action 2')].map(&:as_null_object)
      expect(actions[0]).to receive(:perform).with(browser, values)
      expect(actions[1]).to receive(:perform).with(browser, values)
      CongressForms::WebForm.new(actions).fill(values, browser: browser)
    end
  end
end
