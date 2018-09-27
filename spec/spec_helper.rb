require "pry"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "congress_forms"

Dir["spec/support/**/*.rb"].each{ |f| require(File.expand_path(f)) }

def cwc_client_params
  {
    api_key: "api_key",
    host: "https://cwc.house.gov.example.org",
    delivery_agent: "delivery_agent",
    delivery_agent_ack_email: "delivery_agent_ack_email",
    delivery_agent_contact_name: "delivery_agent_contact_name",
    delivery_agent_contact_email: "delivery_agent_contact_email",
    delivery_agent_contact_phone: "delivery_agent_contact_phone"
  }
end

def cwc_message_params
  {
    campaign_id: "campaign_id",
    organization: {
      name: "delivery_organization",
      about: "delivery_organization_about",
      contact: {
        name: "delivery_organization_contact_name",
        email: "delivery_organization_contact_email",
        phone: "delivery_organization_contact_phone"
      }
    },
    
    recipient: {
      member_office: "member_office",
      is_response_requested: true,
      newsletter_opt_in: true
    },
    
    constituent: {
      prefix: "prefix",
      first_name: "first_name",
      middle_name: "middle_name",
      last_name: "last_name",
      suffix: "suffix",
      title: "title",
      organization: "constituent_organization",
      address: ["address1", "address2", "address3"],
      city: "city",
      state_abbreviation: "state_abbreviation",
      zip: "zip_code",
      email: "email",
      phone: "phone",
      address_validation: true,
      email_validation: true
    },
    
    message: {
      subject: "message_subject",
      library_of_congress_topics: ["library_of_congress_topic1", "library_of_congress_topic2"],
      constituent_message: "constituent_message",
      organization_statement: "organization_statement",
      more_info: "more_info",
      bills: [
        {
          congress: "bill_congress",
          type_abbreviation: "bill_type_abbreviation",
          number: "bill_number1"
        },
        {
          congress: "bill_congress",
          type_abbreviation: "bill_type_abbreviation",
          number: "bill_number2"
        }
      ],
      pro_or_con: "pro_or_con"
    }
  }
end

Cwc::Client.configure(cwc_client_params)

