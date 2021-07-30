# frozen_string_literal: true

module Mutations
  module Concerns
    module KamInvestor
      extend ActiveSupport::Concern

      included do
        argument :kam_id, GraphQL::Types::ID, required: false
        argument :investor_id, String, required: false
        argument :investor_description, String, required: false
      end
    end
  end
end
