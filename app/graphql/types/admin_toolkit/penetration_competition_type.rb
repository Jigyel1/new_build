# frozen_string_literal: true

module Types
  module AdminToolkit
    class PenetrationCompetitionType < BaseObject
      field :id, ID, null: true
      field :competition, AdminToolkit::CompetitionType, null: true
    end
  end
end
