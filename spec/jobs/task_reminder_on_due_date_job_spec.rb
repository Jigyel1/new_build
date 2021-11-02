# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskReminderOnDueDateJob, type: :job do
  include ActiveJob::TestHelper

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:task) { create(:task, taskable: building, assignee: kam, owner: super_user) }

  describe '#perform_later' do
    it 'sends a reminder on due date' do
      ActiveJob::Base.queue_adapter = :test
      on_due_date = described_class.set(wait_until: task.due_date.to_time + 17.hours)
                                   .perform_later(kam.id, task.id)
      expect(on_due_date.arguments[0]).to eq(kam.id)

      expect do
        described_class.set(wait_until: task.due_date.to_time + 17.hours)
                       .perform_later(kam.id, task.id)
      end.to have_enqueued_job

      perform_enqueued_jobs
    end
  end
end
