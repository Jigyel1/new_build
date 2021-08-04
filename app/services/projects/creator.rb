# frozen_string_literal: true

# A project will be assigned to NBO/KAM in the following different ways:
# If a project has more than 50 homes then such types of projects will be assigned to KAM. This assignment will be done based on the settings of “KAM Regions” in the Penetration tab from the Admin toolkit.
# If a project has a specific landlord, then such projects will be assigned to certain KAMs who are assigned those landlords. This assignment will be done based on the settings in the “Assign KAM” tab from the Admin toolkit.
# If a project is newly uploaded/created into the New Build portal but if no above criterias are there for that project then it will be assigned to the NBO team and any other person who clicks on that project will be automatically assigned.
# If a project is assigned to a KAM (scenarios 1 and 2), then the system generated label “KAM Project” will be added to the project. If it is assigned to the NBO team (scenario 3), then the system generated label “NBO Project” will be added to the project.

module Projects
  class Creator < BaseService
    attr_reader :project

    def call
      authorize! ::Project, to: :create?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        @project = ::Project.create!(attributes)
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_created,
        owner: current_user,
        trackable: project,
        parameters: attributes
      }
    end
  end
end
