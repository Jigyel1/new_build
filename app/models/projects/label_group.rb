# frozen_string_literal: true

module Projects
  class LabelGroup < ApplicationRecord
    belongs_to :project

    # optional for the default label group.
    # Default label group will have labels for the project itself and are no deletable.
    belongs_to :label_group, class_name: 'AdminToolkit::LabelGroup', optional: true

    after_save :update_project

    def label_list=(value)
      return unless value

      entries = value.split(',').map(&:strip)
      super(entries.uniq)
    end

    private

    def update_project
      project.update_column(:label_list, project.label_groups.pluck(:label_list).flatten.uniq)
    end
  end
end
