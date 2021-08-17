# frozen_string_literal: true

module Projects
  module AddressBookHelper
    prepend CustomAssigner

    def call
      super do
        assign_attributes
        assign_address_attributes
        assign_kam
      end
    end

    private

    def assign_address_attributes
      attributes = row_mappings("#{type}_address")
      super(attributes_hash(attributes), address_book)
    end

    def assign_kam
      project_assignee = Projects::Assignee.new(project)
      project_assignee.call
      project.assignee = project_assignee.kam
    end
  end
end
