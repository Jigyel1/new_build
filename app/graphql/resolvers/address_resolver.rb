# frozen_string_literal: true

module Resolvers
  class AddressResolver < SearchObjectBase
    scope { Address.all }

    type Types::AddressConnectionType, null: false

    option(:addressable_types, type: [String], required: true, description: <<~DESC
      Supported options - "Telco::Uam::User, Project, Projects::Building, Projects::AddressBook"
    DESC
    ) do |scope, value|
      scope.where(addressable_type: value)
    end

    option(:zips, type: [String]) { |scope, value| scope.where(zip: value) }
    option(:cities, type: [String]) { |scope, value| scope.where(city: value) }
    option(:streets, type: [String]) { |scope, value| scope.where(street: value) }

    option :query, type: String, with: :apply_search, description: <<~DESC
      Supports searches on street, city, street no and zip
    DESC

    private

    def apply_search(scope, value)
      scope.where("CONCAT_WS(' ', street, street_no, city, zip) iLIKE ?", "%#{value.squish}%")
    end
  end
end
