# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskReminderOnDueDateJob, type: :job do
  include ActiveJob::TestHelper

  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:due_date_time) { DateTime.tomorrow.to_time + 9.hours }

  describe '#perform_later' do
    it 'sends a reminder on due date' do
      ActiveJob::Base.queue_adapter = :test
      on_due_date = described_class.set(wait_until: due_date_time).perform_later(kam.id)
      expect(on_due_date.arguments[0]).to eq(kam.id)

      expect do
        described_class.set(wait_until: due_date_time).perform_later(kam.id)
      end.to have_enqueued_job

      perform_enqueued_jobs
    end
  end
end
