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

    def log_data
      # LogFormatter.new(object.log_data).call
    end
  end
end
