# frozen_string_literal: true

module Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :email, String, null: true
    field :name, String, null: true
    field :role_id, ID, null: true
    field :active, Boolean, null: true
    field :discarded_at, GraphQL::Types::ISO8601DateTime, null: true, description: 'When the user got deleted'

    field :role, Types::RoleType, null: true
    field :profile, Types::ProfileType, null: true
    field :address, Types::AddressType, null: true

    field :log_data, [GraphQL::Types::JSON], null: true

    # TODO: Log data to be implemented when the next PR(#ActivityStream)
    def log_data
      # LogFormatter.new(object.log_data).call
    end

    def role
      BatchLoaders::AssociationLoader.for(object.class, :role).load(object)
    end

    def profile
      BatchLoaders::AssociationLoader.for(object.class, :profile).load(object)
    end

    def address
      BatchLoaders::AssociationLoader.for(object.class, :address).load(object)
    end
  end
end
