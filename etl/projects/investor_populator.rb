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

    # Project assignee is set here as it depends on the investor mappings.
    # TODO: Add spec for this assignment also.
    #   Set the project type too as either KAM or NBO project!
    def assign_kam
      project_assignee = Projects::Assignee.new(project)
      project_assignee.call
      project.assignee = project_assignee.kam
    end
  end
end
