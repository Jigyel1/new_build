# frozen_string_literal: true

module Resolvers
  module Projects
    class TasksResolver < SearchObjectBase
      VALID_TASKABLE_TYPES = ['Project', 'Projects::Building'].freeze

      scope { ::Projects::Task }

      type Types::Projects::TaskConnectionType, null: false

      option :taskable, type: [String], with: :apply_taskable_filter, required: false, description: <<~DESC
        Takes in two arguments. First, the taskable id(project or the building id).
        Second, the taskable type(when project then `Project`, when building then `Projects::Building`).
        Note that this option is mandatory!
      DESC

      option(:user_id, type: String) { |scope, value| find_created_or_assigned(scope, value) }
      option(:assignee_id, type: String) { |scope, value| scope.where(assignee_id: value) }
      option(:owner_id, type: String) { |scope, value| scope.where(owner_id: value) }
      option(:taskable_type, type: String) { |scope, value| scope.where(taskable_type: value) }
      option(:statuses, type: [String]) { |scope, value| scope.where(status: value) }
      option :query, type: String, with: :apply_search

      def apply_taskable_filter(scope, value)
        taskable_id, taskable_type = value
        unless VALID_TASKABLE_TYPES.include?(taskable_type)
          raise I18n.t('projects.task.invalid_taskable_type',
                       valid_types: VALID_TASKABLE_TYPES.to_sentence)
        end

        scope.where(taskable_id: taskable_id, taskable_type: taskable_type)
      end

      def apply_search(scope, value)
        scope.joins(assignee: :profile).where(
          "CONCAT_WS(
          ' ',
          profiles.firstname,
          profiles.lastname,
          telco_uam_users.email,
          projects_tasks.title,
          projects_tasks.description,
          projects_tasks.due_date,
          projects_tasks.status
        )
        iLIKE ?", "%#{value.squish}%"
        )
      end

      def find_created_or_assigned(scope, value)
        scope.where('assignee_id = ? or owner_id = ?', value, value)
      end
    end
  end
end
