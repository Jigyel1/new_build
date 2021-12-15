# frozen_string_literal: true

module Mutations
  class UpdateProject < BaseMutation
    class UpdateProjectAddressAttributes < Types::BaseInputObject
      # id is optional. you can still add addresses to an existing project.
      include Concerns::Address
    end

    class UpdateProjectAttributes < Types::BaseInputObject
      argument :id, ID, required: true
      argument :internal_id, ID, required: false
      argument :os_id, ID, required: false
      argument :name, String, required: false
      argument :status, String, required: false
      argument :description, String, required: false
      argument :additional_info, String, required: false
      argument :assignee_id, ID, required: false

      argument :coordinate_east, Float, required: false
      argument :coordinate_north, Float, required: false

      argument :construction_type, String, required: false
      argument :building_type, String, required: false
      argument :lot_number, String, required: false
      argument :construction_starts_on, String, required: false
      argument :gis_url, String, required: false
      argument :info_manager_url, String, required: false

      argument :address, UpdateProjectAddressAttributes, required: false, as: :address_attributes
    end

    argument :attributes, UpdateProjectAttributes, required: true
    field :project, Types::ProjectType, null: true

    def resolve(attributes:)
      super(::Projects::Updater, :project, attributes: attributes.to_h)
    end
  end
end
