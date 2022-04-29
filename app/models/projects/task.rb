# frozen_string_literal: true

module Projects
  class Task < ApplicationRecord
    include Trackable
    include Hooks::Task

    # taskable can be a building or a project.
    belongs_to :taskable, polymorphic: true

    belongs_to :owner, class_name: 'Telco::Uam::User'
    belongs_to :assignee, class_name: 'Telco::Uam::User'

    validates :title, :description, :status, :due_date, presence: true

    default_scope { order(updated_at: :desc) }

    enum status: {
      todo: 'To-Do',
      in_progress: 'In progress',
      completed: 'Completed',
      archived: 'Archived'
    }
  end
end
