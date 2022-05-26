# frozen_string_literal: true

module Projects
  class Creator < BaseService
    attr_reader :project
    attr_accessor :buildings_count, :apartments_count

    set_callback :call, :after, :notify_assignee

    def initialize(params = {})
      @buildings_count = params[:attributes].delete(:buildings_count)
      @apartments_count = params[:attributes].delete(:apartments_count)

      super
    end

    def call
      super do
        authorize! Project, to: :create?

        with_tracking do
          @project = ::Project.new(formatted_attributes)
          update_apartment
          build_associations
          project.save!
        end
      end
    end

    private

    def formatted_attributes
      attributes[:address_books_attributes].each { |attr| attr[:entry_type] = :manual }
      attributes
    end

    def update_apartment
      return if project.site_address.blank?

      project.apartments_count = project.site_address.inject(0) { |sum, index| sum + index['apartments_count'] }
    end

    def build_associations
      BuildingManualBuilder
        .new(project: project, buildings_count: buildings_count)
        .call
      project.assignee_type = :nbo if project.assignee.try(:nbo_team?)

      # set category only after assigning buildings to the project.
      project.category = CategorySetter.new(project: project).call
    end

    def activity_params
      {
        action: :project_created,
        owner: current_user,
        trackable: project,
        parameters: { entry_type: project.entry_type, project_name: project.name }
      }
    end

    def notify_assignee
      return if current_user.id == project.assignee_id

      ProjectMailer.notify_assigned(:assignee, project.assignee_id, project.id, current_user.id).deliver_later
    end
  end
end
