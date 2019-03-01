module CongressForms
  class CwcForm < Form
    attr_accessor :office_code

    def initialize(office_code)
      self.office_code = office_code
    end

    def updated_at
      Time.at(0)
    end

    def required_params
      Cwc::RequiredJson.fetch("required_actions").map(&:dup)
    end

    def fill(values, campaign_tag: nil, organization: nil, browser: nil, validate_only: false)
      params = {
        campaign_id: campaign_tag || SecureRandom.hex(16),

        recipient: { member_office: office_code },

        constituent: {
          prefix:	      values["$NAME_PREFIX"],
          first_name:	      values["$NAME_FIRST"],
          last_name:	      values["$NAME_LAST"],
          address:	      Array(values["$ADDRESS_STREET"]),
          city:		      values["$ADDRESS_CITY"],
          state_abbreviation: values["$ADDRESS_STATE_POSTAL_ABBREV"],
          zip:		      values["$ADDRESS_ZIP5"],
          email:	      values["$EMAIL"]
        },

        message: {
          subject:                    values["$SUBJECT"],
          library_of_congress_topics: Array(values["$TOPIC"])
        }
      }

      if organization
        params[:organization] = organization
      end

      if values["$STATEMENT"]
        params[:message][:organization_statement] = values["$STATEMENT"]
      end

      if values["$MESSAGE"] && values["$MESSAGE"] != values["$STATEMENT"]
        params[:message][:constituent_message] = values["$MESSAGE"]
      end

      cwc_client = Cwc::Client.new
      message = cwc_client.create_message(params)

      if validate_only
        cwc_client.validate(message)
      else
        cwc_client.deliver(message)
      end
    end
  end
end
