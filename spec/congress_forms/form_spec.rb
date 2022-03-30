require "spec_helper"

describe CongressForms::Form do
  describe ".find(bioguide)" do
    context "bioguide corresponds to a CWC-supported office" do
      before {
        expect_any_instance_of(Cwc::Client).
          to receive(:office_supported?).
              and_return(true)
      }

      it "should return a CwcForm" do
        bioguide, form = double

        expect(CongressForms::CwcForm).
          to receive(:new).
              with(bioguide).
              and_return(form)

        expect(CongressForms::Form.find(bioguide)).to eq(form)
      end
    end
  end
end
