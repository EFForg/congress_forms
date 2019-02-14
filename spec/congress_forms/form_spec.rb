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

    context "bioguide does not correspond to a CWC-office" do
      before {
        expect_any_instance_of(Cwc::Client).
          to receive(:office_supported?).
              and_return(false)
      }

      it "should lookup the form file and parse it" do
        form_id = SecureRandom.hex(8)
        file, timestamp, form = double, double, double

        expect_any_instance_of(CongressForms::Repo).
          to receive(:find).
              with("members/#{form_id}.yaml").
              and_return([file, timestamp])

        expect(CongressForms::WebForm).
          to receive(:parse).
              with(file, updated_at: timestamp).
              and_return(form)

        expect(CongressForms::Form.find(form_id)).to eq(form)
      end
    end
  end
end
