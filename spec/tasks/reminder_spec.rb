# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

describe 'Reminder' do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:task) { create(:task, taskable: building, assignee: kam, owner: super_user) }
  let_it_be(:task_b) { create(:task, taskable: building, assignee: kam, owner: super_user) }
  let_it_be(:params) { { id: task_b.id, due_date: Date.tomorrow } }

  before_all { Projects::TaskUpdater.new(current_user: super_user, attributes: params).call }

  context 'with task reminder:due_date_tomorrow' do
    it 'triggers mail before due date' do
      Rake::Task['reminder:due_date_tomorrow'].invoke
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to[0]).to eq(kam.email)
    end
  end

  context 'with task reminder:due_date_today' do
    it 'triggers mail on due date' do
      Rake::Task['reminder:due_date_today'].invoke
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to[0]).to eq(kam.email)
    end
  end
end
