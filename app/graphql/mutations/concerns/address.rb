# frozen_string_literal: true

module Mutations
  module Concerns
    module Address
      extend ActiveSupport::Concern

      included do
        argument :id, GraphQL::Types::ID, required: false
        argument :street, String, required: false
        argument :street_no, String, required: false
        argument :city, String, required: false
        argument :zip, String, required: false
      end
    end
  end
end
