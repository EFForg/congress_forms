require "yaml"

require "congress_forms/version"

require "cwc"

unless ENV["CWC_API_KEY"].nil?
  Cwc::Client.configure(
    api_key: ENV["CWC_API_KEY"],
    host: ENV["CWC_HOST"],
    delivery_agent: ENV["CWC_DELIVERY_AGENT"],
    delivery_agent_ack_email: ENV["CWC_DELIVERY_AGENT_ACK_EMAIL"],
    delivery_agent_contact_name: ENV["CWC_DELIVERY_AGENT_CONTACT_NAME"],
    delivery_agent_contact_email: ENV["CWC_DELIVERY_AGENT_CONTACT_EMAIL"],
    delivery_agent_contact_phone: ENV["CWC_DELIVERY_AGENT_CONTACT_PHONE"]
  )
end

module CongressForms
  Error = Class.new(Exception) do
    attr_accessor :screenshot
  end

  autoload :Form, "congress_forms/form"
  autoload :CwcForm, "congress_forms/cwc_form"
end
