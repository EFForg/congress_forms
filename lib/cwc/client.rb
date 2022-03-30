require "ostruct"
require "json"

require "rest-client"

require "cwc/office"
require "cwc/message"
require "cwc/topic_codes"
require "cwc/bad_request"
require "cwc/fixtures"

module Cwc
  class Client
    attr_accessor :options

    class << self
      def default_client_configuration=(x)
        @default_client_configuration = x
      end

      def default_client_configuration
        @default_client_configuration ||= {}
      end

      def configure(options)
        self.default_client_configuration = options
      end
    end

    # Required options keys
    #   api_key                         String
    #   delivery_agent			String, must match the api key owner
    #   delivery_agent_ack_email	String
    #   delivery_agent_contact_name	String
    #   delivery_agent_contact_email	String
    #   delivery_agent_contact_phone	String, format xxx-xxx-xxxx
    def initialize(options={})
      options = self.class.default_client_configuration.merge(options)
      self.options = {
        api_key: options.fetch(:api_key),
        host: options.fetch(:host),

        delivery_agent: {
          name: options.fetch(:delivery_agent),
          ack_email: options.fetch(:delivery_agent_ack_email),
          contact_name: options.fetch(:delivery_agent_contact_name),
          contact_email: options.fetch(:delivery_agent_contact_email),
          contact_phone: options.fetch(:delivery_agent_contact_phone)
        }
      }
    end

    # CWC (House) Params format below
    # SWCW (Senate) Params are the same except for the org
    # {
    #   campaign_id:		String
    #   recipient: {
    #     member_office:		String
    #     is_response_requested:	Boolean	?
    #     newsletter_opt_in:		Boolean	?
    #   },
    #   organization: {
    #     name:		String	?
    #     contact: {
    #       name:	String	?
    #       email:	String	?
    #       phone:	String	?
    #       about:	String	?
    #     }
    #   },
    #   constituent: {
    #     prefix:		String
    #     first_name:		String
    #     middle_name:		String	?
    #     last_name:		String
    #     suffix:		String	?
    #     title:		String	?
    #     organization:		String	?
    #     address:		Array[String]
    #     city:			String
    #     state_abbreviation:	String
    #     zip:			String
    #     phone:		String	?
    #     address_validation:	Boolean	?
    #     email:		String
    #     email_validation:	Boolean	?
    #  },
    #  message: {
    #    subject:			String
    #    library_of_congress_topics:	Array[String], drawn from Cwc::TopicCodes. Must give at least 1.
    #    bills:	{			Array[Hash]
    #      congress:			Integer	?
    #      type_abbreviation:		String
    #      number:			Integer
    #    },
    #    pro_or_con:			"pro" or "con"	?
    #    organization_statement:	String		?
    #    constituent_message:		String		?
    #    more_info:			String (URL)	?
    #  }
    #
    # Use message[:constituent_message] for personal message,
    # or  message[:organization_statement] for campaign message
    # At least one of these must be given
    def create_message(params)
      Cwc::Message.new.tap do |message|
        message.delivery[:agent] = options.fetch(:delivery_agent)
        message.delivery[:organization] = params.fetch(:organization, {})
        message.delivery[:campaign_id] = params.fetch(:campaign_id)

        message.recipient.merge!(params.fetch(:recipient))
        message.constituent.merge!(params.fetch(:constituent))
        message.message.merge!(params.fetch(:message))
      end
    end

    def deliver(message)
      post action(:message), message.to_xml
      true
    rescue RestClient::BadRequest => e
      raise BadRequest.new(e)
    end

    def validate(message)
      post action(:validate), message.to_xml
      true
    rescue RestClient::BadRequest => e
      if senate?
        return false
      else
        raise e
      end
    end

    def office_supported?(office_code)
      !offices.find{ |office| office.code == office_code }.nil?
    end

    def required_json(o={})
      Cwc::RequiredJson.merge(o)
    end

    def offices
      response = get action(:offices)
      JSON.parse(response.body).map{ |code| Office.new(code) }
    end

    protected

    def house?
      !!options[:host]["house.gov"]
    end

    def senate?
      !!options[:host]["senate.gov"]
    end

    def action(action)
      host = options[:host].sub(/\/+$/, '')

      if house?
        case action
        when :offices
          uri = "v2/offices"
        when :message
          uri = "v2/message"
        when :validate
          uri = "v2/validate"
        end
      else senate?
        case action
        when :offices
          uri = "api/active_offices/"
        when :message
          # uri = "api/production-messages/"
          uri = "api/testing-messages/"
        when :validate
          uri = "api/testing-messages/"
        end
      end

      "#{host}/#{uri}?apikey=#{options[:api_key]}"
    end

    private

    def get(url)
      verify = !["false", "0"].include?(ENV["CWC_VERIFY_SSL"])
      headers = { host: ENV["CWC_HOST_HEADER"] }.reject{ |_, v| v.nil? }
      puts url
      RestClient::Resource.new(url, verify_ssl: verify).get(headers)
    end

    def post(url, message)
      verify = !["false", "0"].include?(ENV["CWC_VERIFY_SSL"])

      headers = { content_type: :xml, host: ENV["CWC_HOST_HEADER"] }.
                reject{ |_, v| v.nil? }

      RestClient::Resource.new(url, verify_ssl: verify).
        post(message, headers)
    end
  end
end
