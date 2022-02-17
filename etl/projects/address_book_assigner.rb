# frozen_string_literal: true

module Projects
  module AddressBookAssigner
    prepend CustomAssigner

    def call
      super do
        assign_kam
        assign_attributes
        assign_address_attributes
      end
    end

    private

    def assign_kam
      project_assignee = Projects::Assignee.new(project: project)
      project_assignee.call
      project.assignee = project_assignee.kam

      return if project_assignee.kam.blank?

      ProjectMailer.notify_project_assigned(project.assignee_id, project.name).deliver_later
    end

    def assign_address_attributes
      attributes = row_mappings("#{type}_address")
      super(attributes_hash(attributes), address_book)
    end
  end
end
