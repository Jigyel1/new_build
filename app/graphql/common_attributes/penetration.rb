# frozen_string_literal: true

module CommonAttributes
  module Penetration
    extend ActiveSupport::Concern

    included do
      argument :zip, String, required: false
      argument :city, String, required: false
      argument :rate, String, required: false
      argument :competition, String, required: false
      argument :kam_region, String, required: false
      argument :hfc_footprint, GraphQL::Types::Boolean, required: false
      argument :type, String, required: false
    end
  end
end
