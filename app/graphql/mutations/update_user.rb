# frozen_string_literal: true

module Mutations
  class UpdateUser < BaseMutation
    class ProfileArguments < Types::BaseInputObject
      include CommonArguments::Profile

      argument :id, ID, required: true
    end

    class AddressArguments < Types::BaseInputObject
      include CommonArguments::Address

      argument :id, ID, required: true
    end

    class UpdateArguments < Types::BaseInputObject
      argument :id, ID, required: true
      argument :profile, ProfileArguments, as: :profile_attributes, required: false
      argument :address, AddressArguments, as: :address_attributes, required: false
    end

    argument :attributes, UpdateArguments, required: true
    field :user, Types::UserType, null: true

    def resolve(attributes:)
      resolver = ::Users::UserUpdater.new(current_user: current_user, attributes: attributes.to_h)
      resolver.call

      { user: resolver.user }
    end
  end
end
