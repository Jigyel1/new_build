# frozen_string_literal: true

module AdminToolkit
  class PenetrationsImporter < BaseService
    attr_accessor :file

    def call
      authorize! Project, to: :import?

      ::PenetrationsImporter.call(current_user: current_user, input: file)
    end

    private

    # TODO: to be included
    def activity_params
      {
        action: :penetrations_imported,
        owner: current_user,
        trackable_type: 'AdminToolkit::Penetration',
        parameters: { filename: file.original_filename }
      }
    end
  end
end
