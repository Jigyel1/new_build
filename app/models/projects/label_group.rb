class Projects::LabelGroup < ApplicationRecord
  belongs_to :project
  belongs_to :label_group, class_name: 'AdminToolkit::LabelGroup'

  validates :name, presence: true, uniqueness: true # inclusion: { in: project.statuses }
  # validates :name, to match label group's name

  delegate :manual?, to: :project

  after_save :update_project

  def label_list=(value)
    return unless value

    entries = value.split(',').map(&:strip)
    entries << 'Manually Created' if manual?
    super(entries.uniq)
  end

  def label_list
    return super if super.present?

    label_group.label_list
  end

  private

  # `Manually Created` will repeat for all project stages if the project is manually created.
  # To assign a correct count for the labels, you just need to add 1 for the `Manually Created`
  # labels
  def update_project
    project.update_column(
      :label_list, project.label_groups.flat_map(&:label_list)
    )
  end
end
