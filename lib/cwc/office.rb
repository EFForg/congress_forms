module Cwc
  class Office
    attr_reader :code

    # @param code_or_params [String or Hash]
    #   house.gov /v2/office returns a simple list of office codes
    #   senate.gov /api/active_offices returns a list of structured JSON
    #
    #   either response can be passed directly to Cwc::Office.new(resp)
    #
    def initialize(code_or_params)
      if code_or_params.is_a?(Hash)
        @code = code_or_params.fetch("office_code")
      else
        @code = code_or_params
      end
    end

    def house?
      code[0, 1] == "H"
    end

    def senate?
      code[0, 1] == "S"
    end

    def house_district
      code[-2..-1].to_i
    end

    def senate_class
      code[-1..-1].to_i + 1
    end

    def state
      code[1..2]
    end
  end
end
