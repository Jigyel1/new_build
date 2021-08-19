# frozen_string_literal: true

module Mutations
  module Concerns
    module AddressBook
      extend ActiveSupport::Concern

      included do
        argument :project_id, GraphQL::Types::ID, required: false
        argument :type, String, required: false
        argument :name, String, required: false
        argument :display_name, String, required: false, description: <<~DESC
          For architect & investor, display name will be set the same as the type. If the type is
          others, display name will have a custom name and is REQUIRED!.
        DESC

        argument :additional_name, String, required: false
        argument :company, String, required: false
        argument :po_box, String, required: false
        argument :language, String, required: false
        argument :phone, String, required: false
        argument :mobile, String, required: false
        argument :email, String, required: false
        argument :website, String, required: false
      end
    end
  end
end
