# frozen_string_literal: true

module Types
  class ProjectType < BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :external_id, String, null: true
    field :internal_id, String, null: true

    field :project_nr, String, null: true
    field :status, String, null: true
    field :priority, String, null: true
    field :category, String, null: true
    field :construction_type, String, null: true
    field :assignee_type, String, null: true

    field :verdicts, GraphQL::Types::JSON, null: true

    field :assignee, Types::UserType, null: true
    field :address, Types::AddressType, null: true
    field :kam_region, AdminToolkit::KamRegionType, null: true
    field :address_books, [Projects::AddressBookType], null: true

    field(
      :move_in_starts_on,
      String,
      null: true,
      description: 'From when the tenant can move in.'
    )

    field(
      :move_in_ends_on,
      String,
      null: true,
      description: 'Till when the tenant can move in.'
    )

    field :construction_starts_on, String, null: true

    field :lot_number, String, null: true
    field :buildings_count, Int, null: true
    field :apartments_count, Int, null: true
    field :coordinate_east, Float, null: true
    field :coordinate_north, Float, null: true
    field :description, String, null: true
    field :additional_info, String, null: true
    field :additional_details, GraphQL::Types::JSON, null: true
    field :label_list, [String], null: true

    field :statuses, GraphQL::Types::JSON, null: true, description: <<~DESC
      This will be a list statuses that the given project supports.
    DESC

    %i[move_in_starts_on move_in_ends_on construction_starts_on].each do |method_name|
      define_method method_name do
        in_time_zone(method_name)
      end
    end

    def statuses
      # return { archived: true } if archived?
      #
      # states = aasm.states.map(&:name)
      # states.delete(:awaiting_porting) unless non_premium_porting?
      # states.delete(:awaiting_connection_upgrade) unless upgrade?
      # states.delete_if { |k| %i(awaiting_hardware_dispatch awaiting_installation).include?(k) and upc_installation? }
      # states.delete_if { |k| %i(awaiting_document_upload awaiting_document_verify).include?(k) and !(documents_required? || skip_document_upload?) }
      # states.delete_if { |k| %i(awaiting_installation awaiting_hardware_dispatch awaiting_connection_upgrade).include?(k) and address_not_required? }
      # current = states.index(aasm.current_state)
      # states = states.reject { |s| [:finalized, :closed].include?(s) }
      # states.each_with_index.map { |k, i| [k, i < current] }.to_h
    end
  end
end
