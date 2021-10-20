# frozen_string_literal: true

module Mutations
  module Concerns
    module Competition
      extend ActiveSupport::Concern

      included do
        argument :name, String, required: false
        argument :sfn, GraphQL::Types::Boolean, required: false
        argument :factor, Float, required: false
        argument :lease_rate, String, required: false
        argument :description, String, required: false
      end
    end
  end
end
