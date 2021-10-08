# frozen_string_literal: true

require 'rails_helper'

describe Projects::StatusUpdater do
  let_it_be(:team_expert) { create(:user, :team_expert, with_permissions: { project: :technical_analysis }) }
  let_it_be(:zip) { '1101' }
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost, standard: 99_987) }
  let_it_be(:kam_region) { create(:admin_toolkit_kam_region) }
  let_it_be(:label_group_a) { create(:admin_toolkit_label_group, :technical_analysis_completed) }
  let_it_be(:label_group_b) { create(:admin_toolkit_label_group, :ready_for_offer) }
  let_it_be(:competition) { create(:admin_toolkit_competition) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, zip: zip, kam_region: kam_region, rate: 4.56) }
  let_it_be(:penetration_competition) do
    create(
      :penetration_competition,
      penetration: penetration,
      competition: competition
    )
  end

  let_it_be(:pct_value) do
    create(
      :admin_toolkit_pct_value,
      :prio_two,
      pct_month: create(:admin_toolkit_pct_month, min: 10, max: 17),
      pct_cost: create(:admin_toolkit_pct_cost, min: 1187, max: 100_000)
    )
  end

  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:management) { create(:user, :management, with_permissions: { project: :ready_for_offer }) }
  let_it_be(:address) { build(:address, zip: zip) }
  let_it_be(:project) { create(:project, :technical_analysis, address: address) }
  let_it_be(:building) { create(:building, apartments_count: 30, project: project) }
  let_it_be(:params) { { id: project.id } }

  describe 'Transitions' do
    describe 'Transition to Technical Analysis' do
      let_it_be(:project_b) { create(:project) }
      let_it_be(:params_b) { { id: project_b.id } }

      before_all do
        described_class.new(current_user: team_expert, attributes: params_b, event: :technical_analysis).call
      end
      describe '.activities' do
        context 'as an owner' do
          it 'returns activities in terms of first person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: team_expert)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.technical_analysis.owner',
                project_name: project_b.name,
                status: 'technical_analysis')
            )
          end
        end

        context 'as an general user' do
          let!(:super_user) { create(:user, :super_user) }

          it 'returns activities in terms of third person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.technical_analysis.others', owner_email: team_expert.email,
                                                                project_name: project_b.name,
                                                                status: 'technical_analysis')
            )
          end
        end
      end
    end

    describe 'Transition to technical analysis completed' do
      let!(:super_user_b) do
        create(
          :user,
          :super_user,
          with_permissions: {
            project: %i[
              complex
              technical_analysis_completed
              ready_for_offer
            ]
          }
        )
      end

      before do
        described_class.new(current_user: super_user_b, attributes: params, event: :technical_analysis_completed).call
      end

      describe '.activities' do
        context 'as an owner' do
          it 'returns activities in terms of first person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.technical_analysis_completed.owner', project_name: project.name,
                                                                         status: 'technical_analysis_completed')
            )
          end
        end

        context 'as an general user' do
          let!(:super_user) { create(:user, :super_user) }

          it 'returns activities in terms of third person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.technical_analysis_completed.others', project_name: project.name,
                                                                          status: 'technical_analysis_completed',
                                                                          owner_email: super_user_b.email)
            )
          end
        end
      end
    end

    describe 'Transition to Ready for offer' do
      let(:project_c) { create(:project, :technical_analysis_completed) }
      let(:params_c) { { id: project_c.id } }

      before do
        pct_value.pct_month.update_column(:max, 498)
        create(:projects_pct_cost, :manually_set_payback_period, project: project_c, payback_period: 498)
        described_class.new(current_user: management, attributes: params_c, event: :offer_ready).call
      end

      describe '.activities' do
        context 'as an owner' do
          it 'returns activities in terms of first person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: management)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.ready_for_offer.owner', project_name: project_c.name,
                                                            previous_status: project_c.status,
                                                            status: 'ready_for_offer')
            )
          end
        end

        context 'as an general user' do
          let!(:super_user) { create(:user, :super_user) }

          it 'returns activities in terms of third person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.ready_for_offer.others', project_name: project_c.name,
                                                             previous_status: project_c.status,
                                                             status: 'ready_for_offer',
                                                             owner_email: management.email)
            )
          end
        end
      end
    end

    describe 'Transition to Archived' do
      let!(:super_user_c) { create(:user, :super_user, with_permissions: { project: :archive }) }
      let(:project_d) { create(:project, :technical_analysis_completed) }
      let(:params_d) { { id: project_d.id } }

      before do
        described_class.new(current_user: super_user_c, attributes: params_d, event: :archive).call
      end

      describe '.activities' do
        context 'as an owner' do
          it 'returns activities in terms of first person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_c)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.archived.owner', previous_status: project_d.status,
                                                     project_name: project_d.name)
            )
          end
        end

        context 'as an general user' do
          let!(:super_user) { create(:user, :super_user) }

          it 'returns activities in terms of third person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.archived.others', owner_email: super_user_c.email,
                                                      previous_status: project_d.status,
                                                      project_name: project_d.name)
            )
          end
        end
      end
    end

    describe 'Revert Transition' do
      let(:super_user) do
        create(
          :user,
          :super_user,
          with_permissions: {
            project: %i[
              open
              technical_analysis
              technical_analysis_completed
              ready_for_offer
              complex
            ]
          }
        )
      end
      let(:project_d) { create(:project, :technical_analysis_completed) }
      let(:params_d) { { id: project_d.id } }

      before do
        described_class.new(current_user: super_user, attributes: params_d, event: :revert).call
      end

      describe '.activities' do
        context 'as an owner' do
          it 'returns activities in terms of first person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.reverted.owner', previous_status: project_d.status,
                                                     status: 'technical_analysis',
                                                     project_name: project_d.name)
            )
          end
        end

        context 'as an general user' do
          let!(:super_user_z) { create(:user, :super_user) }

          it 'returns activities in terms of third person' do
            activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_z)
            expect(errors).to be_nil
            expect(activities.size).to eq(1)
            expect(activities.dig(0, :displayText)).to eq(
              t('activities.project.reverted.others', previous_status: project_d.status,
                                                      status: 'technical_analysis',
                                                      project_name: project_d.name,
                                                      owner_email: super_user.email)
            )
          end
        end
      end
    end
  end
end
