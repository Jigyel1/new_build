class Projects::Building < ApplicationRecord
  belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
  belongs_to :project, counter_cache: true

  after_save :update_project

  private

  def update_project
    project.update_column(:apartments_count, project.buildings.sum(:apartments_count))
  end
end
