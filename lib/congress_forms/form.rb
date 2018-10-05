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

    def self.find(bioguide)
      if Cwc::Client.new.office_supported?(bioguide)
        CwcForm.new(bioguide)
      else
        WebForm.parse(repo.find("members/#{bioguide}.yaml"))
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
