# frozen_string_literal: true

require 'rails_helper'

describe Projects::StatusUpdater do
  include ProjectsTransitionSpecHelper

  let_it_be(:zip) { '1101' }
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost, standard: 99_987) }

  let_it_be(:pct_value) do
    create(
      :admin_toolkit_pct_value,
      :prio_two,
      pct_month: create(:admin_toolkit_pct_month, min: 10, max: 17),
      pct_cost: create(:admin_toolkit_pct_cost, min: 1187, max: 100_000)
    )
  end

  let_it_be(:administrator) { create(:user, :administrator) }
  let_it_be(:super_user) do
    create(
      :user,
      :super_user,
      with_permissions: {
        project: %i[archive complex open technical_analysis ready_for_offer]
      }
    )
  end

  let_it_be(:address) { build(:address, zip: zip) }
  let_it_be(:project) { create(:project, :open, address: address, incharge: super_user) }
  let_it_be(:building) { create(:building, apartments_count: 30, project: project) }
  let_it_be(:params) { { id: project.id } }

  describe '.activities' do
    context 'when it transitions to technical analysis' do
      before do
        described_class.new(current_user: super_user, attributes: params, event: :technical_analysis).call
      end

      context 'as an owner' do
        it 'returns activities in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.technical_analysis.owner',
              project_name: project.name,
              status: 'technical_analysis')
          )
        end
      end

      context 'as an general user' do
        it 'returns activities in terms of third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: administrator)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.technical_analysis.others',
              owner_email: super_user.email,
              project_name: project.name,
              status: 'technical_analysis')
          )
        end
      end
    end

    context 'when it transitions to technical analysis completed' do
      let_it_be(:kam_region) { create(:kam_region) }
      let_it_be(:penetration_competition) do
        create(
          :penetration_competition,
          penetration: create(:admin_toolkit_penetration, zip: zip, kam_region: kam_region, rate: 4.56),
          competition: create(:admin_toolkit_competition)
        )
      end

      before do
        project.update_column(:status, :technical_analysis)
        described_class.new(current_user: super_user, attributes: params, event: :technical_analysis_completed).call
      end

      context 'as an owner' do
        it 'returns activities in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.technical_analysis_completed.owner',
              project_name: project.name,
              status: 'technical_analysis_completed')
          )
        end
      end

      context 'as an general user' do
        it 'returns activities in terms of third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: administrator)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.technical_analysis_completed.others',
              project_name: project.name,
              status: 'technical_analysis_completed',
              owner_email: super_user.email)
          )
        end
      end
    end

    context 'when it transitions to ready for offer' do
      before do
        project.update_column(:status, :technical_analysis_completed)
        pct_value.pct_month.update_column(:max, 498)
        create(:projects_pct_cost, :manually_set_payback_period, project: project, payback_period: 498)

        described_class.new(current_user: super_user, attributes: params, event: :offer_ready).call
      end

      context 'as an owner' do
        it 'returns activities in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.offer_ready.owner',
              project_name: project.name,
              previous_status: project.status,
              status: 'ready_for_offer')
          )
        end
      end

      context 'as an general user' do
        it 'returns activities in terms of third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: administrator)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.offer_ready.others',
              project_name: project.name,
              previous_status: project.status,
              status: 'ready_for_offer',
              owner_email: super_user.email)
          )
        end
      end
    end

    context 'with archiving the project' do
      before do
        project.update_column(:status, :technical_analysis_completed)
        described_class.new(current_user: super_user, attributes: params, event: :archive).call
      end

      context 'as an owner' do
        it 'returns activities in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.archive.owner',
              previous_status: project.status,
              project_name: project.name)
          )
        end
      end

      context 'as an general user' do
        it 'returns activities in terms of third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: administrator)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.archive.others',
              owner_email: super_user.email,
              previous_status: project.status,
              project_name: project.name)
          )
        end
      end
    end

    context 'when un archiving the project' do
      before do
        transitions(project, %i[technical_analysis archived])
        described_class.new(current_user: super_user, attributes: params, event: :unarchive).call
      end

      context 'as an owner' do
        it 'returns activities in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.unarchive.owner',
              status: project.previous_status,
              project_name: project.name)
          )
        end
      end

      context 'as an general user' do
        it 'returns activities in terms of third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: administrator)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.unarchive.others',
              owner_email: super_user.email,
              status: project.previous_status,
              project_name: project.name)
          )
        end
      end
    end

    context 'when reverting project transition' do
      before do
        project.update_column(:status, :technical_analysis_completed)
        described_class.new(current_user: super_user, attributes: params, event: :revert).call
      end

      context 'as an owner' do
        it 'returns activities in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.revert.owner',
              previous_status: project.status,
              status: 'technical_analysis',
              project_name: project.name)
          )
        end
      end

      context 'as an general user' do
        it 'returns activities in terms of third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: administrator)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.revert.others',
              previous_status: project.status,
              status: 'technical_analysis',
              project_name: project.name,
              owner_email: super_user.email)
          )
        end
      end
    end
  end
end
