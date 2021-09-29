# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::Task, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:taskable) }
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:assignee) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:due_date) }
  end

  describe 'enums' do
    it do
      expect(subject).to define_enum_for(:status).with_values( # rubocop:disable RSpec/NamedSubject
        todo: 'To-Do',
        in_progress: 'In Progress',
        completed: 'Completed',
        archived: 'Archived'
      ).backed_by_column_of_type(:string)
    end
  end

  describe 'callbacks' do
    let_it_be(:super_user) { create(:user, :super_user) }
    let_it_be(:project) { create(:project) }

    it 'updates counter caches' do
      create(:task, :completed, owner: super_user, assignee: super_user, taskable: project)
      create(:task, :todo, owner: super_user, assignee: super_user, taskable: project)
      create(:task, :in_progress, owner: super_user, assignee: super_user, taskable: project)
      create(:task, :archived, owner: super_user, assignee: super_user, taskable: project)

      expect(project.completed_tasks_count).to eq(1)
      expect(project.tasks_count).to eq(3)
    end

    it 'updates previous state before save' do
      task = create(:task, :in_progress, taskable: project, owner: super_user, assignee: super_user)
      expect(task.previous_status).to eq('todo')

      task.update!(status: :archived)
      expect(task.previous_status).to eq('in_progress')
    end
  end
end
