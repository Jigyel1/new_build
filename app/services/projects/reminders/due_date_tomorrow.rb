# frozen_string_literal: true

module Projects
  module Reminders
    class DueDateTomorrow
      def self.call
        Projects::Task.where(due_date: Date.tomorrow).group_by(&:assignee_id).each do |assignee_id, tasks|
          TaskMailer.notify_before_due_date(assignee_id, tasks).deliver
        end
      end
    end
  end
end
