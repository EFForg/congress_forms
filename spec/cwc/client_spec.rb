
require "ostruct"

require "spec_helper"
require "cwc/client"

describe Cwc::Client do
  let(:cwc) { Cwc::Client.new(cwc_client_params) }

  describe "#create_message" do
    it "should pass through delivery_agent options" do
      message = cwc.create_message(cwc_message_params)
      expect(message.delivery[:agent]).to eq(cwc.options[:delivery_agent])
    end
  end

  describe "#deliver" do
    it "should POST the message to /v2/message as XML, returning true on success" do
      message = double(to_xml: double("Cwc::Message#to_xml"))

      rest_client = double
      expect(RestClient::Resource).
        to receive(:new).
            with(%r{^https://cwc\.house\.gov\.example\.org/v2/message\?apikey=}, anything).
            and_return(rest_client)

      expect(rest_client).
        to receive(:post).
            with(message.to_xml, content_type: :xml).
            and_return(double(code: 200))

      expect(cwc.deliver(message)).to be_truthy
    end

    it "should raise Cwc::BadRequest on failure" do
      message = double(to_xml: nil)

      expect_any_instance_of(RestClient::Resource).to receive(:post) do
        exception = Class.new(RestClient::BadRequest) do
          def response
            OpenStruct.new(body: "")
          end
        end

        raise exception.new
      end

      expect{ cwc.deliver(message) }.to raise_error(Cwc::BadRequest)
    end
  end
end
