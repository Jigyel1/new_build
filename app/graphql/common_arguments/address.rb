module CommonArguments
  module Address
    extend ActiveSupport::Concern

    included do
      graphql_name 'CommonArgumentsAddress'

      argument :id, GraphQL::Types::ID, required: false
      argument :street, String, required: false
      argument :street_no, String, required: false
      argument :city, String, required: false
      argument :zip, String, required: false
    end
  end
end
