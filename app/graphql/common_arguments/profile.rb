module CommonArguments
  module Profile
    extend ActiveSupport::Concern

    included do
      graphql_name 'CommonArgumentsProfile'

      argument :id, GraphQL::Types::ID, required: false
      argument :salutation, String, required: false
      argument :firstname, String, required: false
      argument :lastname, String, required: false
      argument :phone, String, required: false
      argument :department, String, required: false
    end
  end
end
