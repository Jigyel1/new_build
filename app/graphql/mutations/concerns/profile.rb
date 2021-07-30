# frozen_string_literal: true

module Mutations
  module Concerns
    module Profile
      extend ActiveSupport::Concern

      included do
        argument :id, GraphQL::Types::ID, required: false
        argument :salutation, String, required: false
        argument :firstname, String, required: false
        argument :lastname, String, required: false
        argument :phone, String, required: false
        argument :department, String, required: false
      end
    end
  end
end
