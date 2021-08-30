module Projects
  class LabelsFormatter < BaseService
    # Add all project level labels to this list. They will be counted only once.
    PROJECT_LABELS = [Projects::LabelGroup::MANUALLY_CREATED].freeze

    attr_accessor :project, :label_list
    delegate :manual?, to: :project

    def call
      @label_list =  manual? ? [Projects::LabelGroup::MANUALLY_CREATED] : []
      @label_list += labels_by_project_statuses
    end

    private

    def labels_by_project_statuses
      all_labels - PROJECT_LABELS
    end

    def all_labels
      project.label_groups.pluck(:label_list).flatten
    end
  end
end