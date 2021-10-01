# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::TasksResolver do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:administrator) { create(:user, :administrator) }
  let_it_be(:project) { create(:project, assignee: super_user) }
  let_it_be(:building) { create(:building, assignee: administrator, project: project) }

  let_it_be(:task_a) do
    create(
      :task,
      taskable: project,
      owner: super_user,
      assignee: super_user,
      title: 'Floor panelling',
      description: 'Ensure that the marble slabs are fitted well with proper drainage',
      due_date: 3.days.from_now
    )
  end

  let_it_be(:task_b) do
    create(
      :task,
      :in_progress,
      taskable: project,
      owner: super_user,
      assignee: super_user,
      title: 'Wall panelling',
      description: 'Wood has to be walnut and painted black',
      due_date: 5.days.from_now
    )
  end

  let_it_be(:task_c) do
    create(
      :task,
      :completed,
      taskable: building,
      owner: super_user,
      assignee: super_user,
      title: 'Roofing',
      description: 'Top quality TATA CGI sheets to be used',
      due_date: 1.week.from_now
    )
  end

  let_it_be(:task_d) do
    create(
      :task,
      taskable: project,
      owner: super_user,
      assignee: administrator,
      title: 'Look for labourers',
      description: 'Need at least 10 workers to complete the wall panelling in 5 days',
      due_date: 5.days.from_now
    )
  end

  let_it_be(:task_e) do
    create(
      :task,
      taskable: building,
      owner: super_user,
      assignee: administrator,
      title: 'Get loan',
      description: 'Check with BDBL first as the interest rate is the lowest there',
      due_date: 3.days.from_now
    )
  end

  describe '.resolve' do
    context 'without filters' do
      it 'returns all tasks' do
        tasks, errors = paginated_collection(:tasks, query, current_user: super_user)
        expect(errors).to be_nil
        expect(tasks.pluck(:id)).to eq(project.tasks.pluck(:id))
      end
    end

    context 'with assignee filter' do
      it 'returns tasks assigned to the assigner' do
        tasks, errors = paginated_collection(:tasks, query(assignee_ids: [super_user.id]), current_user: super_user)
        expect(errors).to be_nil
        expect(tasks.pluck(:id)).to eq([task_b.id, task_a.id])
      end
    end

    context 'with status filter' do
      let!(:params) { { statuses: %w[todo completed], taskable: [building.id, 'Projects::Building'] } }

      it 'returns tasks with the given statuses' do
        tasks, errors = paginated_collection(:tasks, query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(tasks.pluck(:id)).to eq([task_e.id, task_c.id])
      end
    end

    context 'with taskable filter' do # a taskable item can be a project or a building
      it 'returns tasks for the given taskable item' do
        tasks, errors = paginated_collection(:tasks, query(taskable: [building.id, 'Projects::Building']),
                                             current_user: super_user)
        expect(errors).to be_nil
        expect(tasks.pluck(:id)).to eq([task_e.id, task_c.id])
      end
    end

    context 'with search queries' do
      it 'returns tasks matching the query' do
        tasks, errors = paginated_collection(:tasks, query(query: 'panelling'), current_user: super_user)
        expect(errors).to be_nil
        expect(tasks.pluck(:id)).to eq([task_d.id, task_b.id, task_a.id])
      end
    end

    describe 'pagination' do
      context 'with first N filter' do
        it 'returns the first N tasks' do
          tasks, errors = paginated_collection(:tasks, query(first: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(tasks.pluck(:id)).to eq([task_d.id, task_b.id])
        end
      end

      context 'with skip N filter' do
        it 'returns tasks after skipping N records' do
          tasks, errors = paginated_collection(:tasks, query(skip: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(tasks.pluck(:id)).to eq([task_a.id])
        end
      end

      context 'with first N & skip M filter' do
        it 'returns first N tasks after skipping M records' do
          tasks, errors = paginated_collection(:tasks, query(first: 2, skip: 1), current_user: super_user)
          expect(errors).to be_nil
          expect(tasks.pluck(:id)).to eq([task_b.id, task_a.id])
        end
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        tasks, errors = paginated_collection(:tasks, query(first: 2, skip: 2), current_user: create(:user, :presales))
        expect(errors).to eq(['Not Authorized'])
        expect(tasks).to be_nil
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        tasks#{query_string(args)} {
          totalCount
          edges {
            node { id title description assignee { email } }
          }
          pageInfo {
            endCursor
            startCursor
            hasNextPage
            hasPreviousPage
          }
        }
      }
    GQL
  end

  def query_string(args = {}) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
    params = args[:statuses] ? ["statuses: #{args[:statuses]}"] : []
    params += ["assigneeIds: #{args[:assignee_ids]}"] if args[:assignee_ids]
    params += if args[:taskable]
                ["taskable: #{args[:taskable]}"]
              else
                ["taskable: #{[project.id, 'Project']}"]
              end

    params << "first: #{args[:first]}" if args[:first]
    params << "skip: #{args[:skip]}" if args[:skip]
    params << "query: \"#{args[:query]}\"" if args[:query]
    params.empty? ? nil : "(#{params.join(',')})"
  end
end
