# frozen_string_literal: true

module Types
  module Projects
    class InstallationDetailType < BaseObject
      field :id, ID, null: true
      field :sockets, Int, null: true
      field :builder, String, null: true
    end
  end
end
