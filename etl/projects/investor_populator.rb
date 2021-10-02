# frozen_string_literal: true

module Projects
  class InvestorPopulator < BasePopulator
    include AddressBookHelper
    include DefaultRoleHelper

    def assign_attributes
      super
      assign_kam
    end

    private

    def assign_kam
      project_assignee = Projects::Assignee.new(project)
      project_assignee.call
      project.assignee = project_assignee.kam
    end
  end
end
