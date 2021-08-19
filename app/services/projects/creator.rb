# frozen_string_literal: true

require_relative '../../../app/models/admin_toolkit'

module Projects
  class Creator < BaseService
    attr_reader :project
    attr_accessor :buildings_count, :apartments_count

    def initialize(params = {})
      @buildings_count = params[:attributes].delete(:buildings_count)
      @apartments_count = params[:attributes].delete(:apartments_count)

      super
    end

    def call
      authorize! Project, to: :create?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        @project = ::Project.new(formatted_attributes)
        build_associations
        project.save!
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def formatted_attributes
      attributes[:address_books_attributes].each { |attr| attr[:entry_type] = :manual }
      attributes
    end

    def build_associations
      project.assignee_type = :nbo if project.assignee.nbo_team?

      buildings_count.to_i.times.each do |index|
        project.buildings.build(
          name: "#{project.name} #{index}",
          assignee: project.assignee,
          apartments_count: grouped_apartments[index].size,
          move_in_starts_on: project.move_in_starts_on,
          move_in_ends_on: project.move_in_ends_on
        )
      end
    end

    def grouped_apartments
      @_grouped_apartments ||= (1..apartments_count).to_a.in_groups(buildings_count, false)
    end

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
