class Projects::LabelGroup < ApplicationRecord
  SYSTEM_GENERATED = 'System Generated'

  belongs_to :project

  # optional for the default label group.
  # Default label group will have labels for the project itself and are no deletable.
  belongs_to :label_group, class_name: 'AdminToolkit::LabelGroup', optional: true

  validates :name, presence: true, uniqueness: {scope: :project_id} # inclusion: { in: project.statuses }
  # validates :name, to match label group's name

  before_validation :set_name
  after_save :update_project

  def label_list=(value)
    return unless value

    entries = value.split(',').map(&:strip)
    super(entries.uniq)
  end

  private

  def set_name
    self.name ||= label_group.name
  end

  def update_project
    project.update_column(:label_list, project.label_groups.pluck(:label_list).flatten.uniq)
  end
end
