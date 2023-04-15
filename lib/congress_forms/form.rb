module CongressForms
  class Form
    @@repo = nil

    def self.repo
      @@repo ||=
        Repo.new(CongressForms.contact_congress_remote).tap do |repo|
          repo.location = CongressForms.contact_congress_repository
          repo.auto_update = CongressForms.auto_update_contact_congress?
        end
    end

    def self.find(form_id)
      begin
        cwc_client = Cwc::Client.new
      rescue KeyError => _
        nil
      end

      if (cwc_client&.office_supported?(form_id) rescue nil)
        CwcForm.new(form_id)
      else
        content, timestamp = repo.find("members/#{form_id}.yaml")
        WebForm.parse(content, updated_at: timestamp)
      end
    rescue Errno::ENOENT => e
      nil
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
