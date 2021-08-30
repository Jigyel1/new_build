class Projects::LabelGroup < ApplicationRecord
  MANUALLY_CREATED = 'Manually Created'

  belongs_to :project
  belongs_to :label_group, class_name: 'AdminToolkit::LabelGroup'

  validates :name, presence: true, uniqueness: true # inclusion: { in: project.statuses }
  # validates :name, to match label group's name

  delegate :manual?, to: :project

  before_validation :set_name
  after_save :update_project

  def label_list=(value)
    return unless value

    entries = value.split(',').map(&:strip)
    entries << MANUALLY_CREATED if manual?
    super(entries.uniq)
  end

  private

  def set_name
    self.name ||= label_group.name
  end

  # `Manually Created` will repeat for all project stages if the project is manually created.
  # To assign a correct count for the labels, you just need to add 1 for the `Manually Created`
  # labels
  # Also don't use pluck or any direct db query as you will need to pick those from admin toolkit too.
  def update_project
    labels_formatter = Projects::LabelsFormatter.new(project: project)
    labels_formatter.call

    project.update_column(:label_list, labels_formatter.label_list)
  end
end
