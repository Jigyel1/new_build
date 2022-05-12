# frozen_string_literal: true

module Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :email, String, null: true
    field :name, String, null: true
    field :role_id, ID, null: true
    field :active, Boolean, null: true

    field(
      :discarded_at,
      GraphQL::Types::ISO8601DateTime,
      null: true,
      description: 'When the user got deleted.'
    )

    field :role, Types::RoleType, null: true
    field :profile, Types::ProfileType, null: true
    field :address, Types::AddressType, null: true

    field :kam_regions, [Types::AdminToolkit::KamRegionType], null: true
    field :kam_investors, [Types::AdminToolkit::KamInvestorType], null: true

    field :projects_count, Integer, null: true
    field :assigned_projects_count, Integer, null: true
    field :assigned_tasks_count, Integer, null: true

    # This will be used to render appropriate modals in the browser based
    # on the presence or absence of the given association and will only be
    # triggered when deleting a user.
    %i[projects assigned_projects assigned_tasks].each do |assoc|
      define_method "#{assoc}_count" do
        object.public_send(assoc).count
      end
    end
  end
end
