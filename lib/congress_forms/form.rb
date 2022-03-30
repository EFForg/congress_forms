module CongressForms
  class Form
    def self.find(form_id)
      begin
        cwc_client = Cwc::Client.new
      rescue KeyError => _
        return nil
      end

      if cwc_client&.office_supported?(form_id)
        CwcForm.new(form_id)
      else
        nil
      end
    end

    def missing_required_params(params)
      missing_parameters = []

      required_params.each do |field|
        unless params.include?(field[:value])
          missing_parameters << field[:value]
        end
      end

      missing_parameters.empty? ? nil : missing_parameters.any
    end
  end
end
