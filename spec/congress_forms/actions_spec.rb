require "spec_helper"

describe CongressForms::Actions do
  let(:browser) { CongressForms::WebForm.create_browser }

  before do
    if defined?(page)
      t = Tempfile.create(['rspec', '.html']).tap do |f|
        f.write(page)
        f.flush
      end

      browser.visit("file://#{t.path}")
    end
  end

  describe "#build(step)" do
    it "should find the right subclass based on step's hash key" do
      action = CongressForms::Actions.build(
        "visit" => "https://www.eff.org/"
      ).first

      expect(action).to be_a(CongressForms::Actions::Visit)
    end

    it "should set #value weirdly for visits" do
      action = CongressForms::Actions.build(
        "visit" => "https://www.eff.org/"
      ).first

      expect(action.value).to eq("https://www.eff.org/")
    end

    it "should set attributes intuitively for other classes" do
      actions = CongressForms::Actions.build(
        "fill_in" => [
          {
            "selector" => "selector0",
            "value" => "value0",
          },
          {
            "selector" => "selector1",
            "value" => "value1",
          }
        ]
      )

      expect(actions[0].selector).to eq("selector0")
      expect(actions[0].value).to eq("value0")

      expect(actions[1].selector).to eq("selector1")
      expect(actions[1].value).to eq("value1")
    end
  end

  describe CongressForms::Actions::Visit do
    let(:visit) {
      CongressForms::Actions.build(
        "visit" => "https://www.eff.org/"
      ).first
    }

    it "should navigate the browser to the url at #value" do
      expect(browser.current_url).not_to eq(visit.value)

      visit.perform(browser)

      expect(browser.current_url).to eq(visit.value)
    end
  end

  describe CongressForms::Actions::Wait do
    let(:wait) {
      CongressForms::Actions.build(
        "wait" => [{ "value" => 7 }]
      ).first
    }

    it "should sleep for #value seconds" do
      expect(wait).to receive(:sleep).with(wait.value)
      wait.perform(browser)
    end
  end

  describe CongressForms::Actions::FillIn do
    let(:fill_in) {
      CongressForms::Actions.build(
        "fill_in" => [{ "selector" => "#input1", "value" => "" }]
      ).first
    }

    let(:page) {
      %(
        <input id="#{fill_in.selector[1..-1]}" type="text" />
      )
    }

    context "#value is a placeholder" do
      before { fill_in.value = "$FIRST_NAME" }

      it "should set the value of #selector correctly" do
        fill_in.perform(browser, { "$FIRST_NAME" => "EFF" })
        expect(browser.find(fill_in.selector).value).to eq("EFF")
      end

      context "#options[max_length] is present" do
        it "should fill in #selector with a truncated value" do
          fill_in.options["max_length"] = 10

          value = ("a".."z").to_a.join
          fill_in.perform(browser, "$FIRST_NAME" => value)

          expect(browser.find(fill_in.selector).value).
            to eq(value[0, fill_in.options["max_length"] - 1])
        end
      end
    end

    context "#value is not a placeholder" do
      before { fill_in.value = "EFF" }

      it "should set the value of #selector to #value" do
        fill_in.perform(browser)
        expect(browser.find(fill_in.selector).value).
          to eq(fill_in.value)
      end
    end

    context "#selector is not on the page" do
      before { fill_in.selector << "-invalidate" }

      it "should raise an error" do
        expect{ fill_in.perform(browser) }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe CongressForms::Actions::Select do
    let(:select) {
      CongressForms::Actions.build(
        "select" => [{ "selector" => "#input1", "value" => "" }]
      ).first
    }

    let(:page) {
      %(
        <select id="#{select.selector[1..-1]}">
         <option value="wrong">wrong option</option>
         <option value="right">correct option</option>
        </select>
       )
    }

    context "#value is a placeholder" do
      before { select.value = "$TOPIC" }

      it "should select the correct option based on value" do
        select.perform(browser, "$TOPIC" => "right")
        expect(browser.find("#input1 option:checked").value).
          to eq("right")
      end

      it "should select the correct option based on text match" do
        select.perform(browser, "$TOPIC" => "correct")
        expect(browser.find("#input1 option:checked").value).
          to eq("right")
      end
    end

    context "#value is not a placeholder" do
      it "should select the correct option based on value" do
        select.value = "right"
        select.perform(browser)
        expect(browser.find("#input1 option:checked").value).
          to eq("right")
      end

      it "should select the correct option based on text match" do
        select.value = "correct"
        select.perform(browser)
        expect(browser.find("#input1 option:checked").value).
          to eq("right")
      end
    end

    context "#selector is not on the page" do
      before { select.selector << "-invalidate" }

      it "should raise an error" do
        expect{ select.perform(browser) }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe CongressForms::Actions::ClickOn do
    let(:click_on) {
      CongressForms::Actions.build(
        "click_on" => [{ "selector" => "#input1", "value" => "" }]
      ).first
    }

    let(:page) {
      %(
        <input id="#{click_on.selector[1..-1]}" type="checkbox" />
      )
    }

    it "should find #selector and click on it" do
      expect(browser.find(click_on.selector)).not_to be_checked
      click_on.perform(browser)
      expect(browser.find(click_on.selector)).to be_checked
    end

    context "#selector is not on the page" do
      before { click_on.selector << "-invalidate" }

      it "should raise an error" do
        expect{ click_on.perform(browser) }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe CongressForms::Actions::Find do
    let(:find) {
      CongressForms::Actions.build(
        "find" => [{ "selector" => "#input1", "value" => "Here I am" }]
      ).first
    }

    let(:page) {
      %(
        <span id="#{find.selector[1..-1]}">#{find.value}</span>
      )
    }

    context "#value is nil" do
      before { find.value = nil }

      it "should find #selector on the page" do
        expect{ find.perform(browser) }.not_to raise_error
      end

      it "should raise an error if #selector is not on the page" do
        find.selector << "-invalidate"
        expect{ find.perform(browser) }.
          to raise_error(Capybara::ElementNotFound)
      end
    end

    context "#value is not nil" do
      it "should find #value in #selector on the page" do
        expect{ find.perform(browser) }.not_to raise_error
      end

      it "should raise an error if it can't" do
        find.selector << "-invalidate"
        expect{ find.perform(browser) }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end


  describe CongressForms::Actions::Check do
    let(:check) {
      CongressForms::Actions.build(
        "check" => [{ "selector" => "#input1", "value" => "" }]
      ).first
    }

    let(:page) {
      %(
        <input id="#{check.selector[1..-1]}" type="checkbox" />
      )
    }

    it "should check #selector" do
      expect(browser.find(check.selector)).not_to be_checked
      check.perform(browser)
      expect(browser.find(check.selector)).to be_checked
    end
  end

  describe CongressForms::Actions::Uncheck do
    let(:uncheck) {
      CongressForms::Actions.build(
        "uncheck" => [{ "selector" => "#input1", "value" => "" }]
      ).first
    }

    let(:page) {
      %(
        <input id="#{uncheck.selector[1..-1]}" type="checkbox" checked/>
      )
    }

    it "should uncheck #selector" do
      expect(browser.find(uncheck.selector)).to be_checked
      uncheck.perform(browser)
      expect(browser.find(uncheck.selector)).not_to be_checked
    end
  end

  describe CongressForms::Actions::Choose do
    let(:choose) {
      CongressForms::Actions.build(
        "choose" => [{ "selector" => ".input1", "value" => "" }]
      ).first
    }

    let(:page) {
      %(
        <input class="#{choose.selector[1..-1]}" type="radio" value=0 />
        <input class="#{choose.selector[1..-1]}" type="radio" value=1 />
      )
    }

    context "#options is present" do
      before {
        choose.options = { dummy: true }
        choose.value = "$FIRST_NAME"
      }

      it "should choose the right input" do
        choose.perform(browser, "$FIRST_NAME" => "1")
        expect(browser.find("input:checked").value).to eq("1")
      end
    end

    context "#options is not present" do
      it "should choose #selector" do
        choose.selector << '[value="1"]'
        choose.perform(browser)
        expect(browser.find("input:checked").value).to eq("1")
      end
    end
  end

  describe CongressForms::Actions::Javascript do
    let(:javascript) {
      CongressForms::Actions.build(
        "javascript" => [{ "value" => "" }]
      ).first
    }

    let(:page) {
      %(
        <input id="input1" type="radio" value=0 />
      )
    }

    it "should evaluate #value" do
      javascript.value =
        "document.querySelector('#input1').checked = true;"

      javascript.perform(browser)

      expect(browser.find("#input1")).to be_checked
    end
  end
end
