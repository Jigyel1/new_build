# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/ips_helper'

RSpec.describe Resolvers::ActivitiesResolver do
  include ActivitiesSpecHelper
  include IpsHelper

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:administrator) { create(:user, :administrator) }
  let_it_be(:super_user_a) { create(:user, :super_user) }
  let_it_be(:management) { create(:user, :management) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_a) { create(:user, :kam) }
  let_it_be(:project) { create(:project, assignee: kam, kam_assignee: kam, project_nr: '2222') }
  let_it_be(:building) { create(:building, project: project, external_id: '112233') }
  before_all { create_activities }

  describe '.resolve' do
    context 'as an owner' do
      it 'returns relevant activities' do
        activities, errors = paginated_collection(:activities, query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_updated.owner',
              recipient_email: kam.email),
            t('activities.telco.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam),
            t('activities.telco.profile_deleted.owner',
              recipient_email: management.email),
            t('activities.telco.status_updated.owner',
              recipient_email: management.email, status_text: t('activities.deactivated')),
            t('activities.telco.user_invited.owner',
              recipient_email: administrator.email, role: :administrator)
          ]
        )
      end
    end

    context 'as a recipient #administrator' do
      it 'returns relevant activities' do
        activities, errors = paginated_collection(:activities, query, current_user: administrator)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_updated.others',
              owner_email: super_user.email, recipient_email: kam.email),
            t('activities.telco.role_updated.others', owner_email: super_user.email, recipient_email: kam.email,
                                                      role: :super_user, previous_role: :kam),
            t('activities.telco.profile_deleted.others', owner_email: super_user.email,
                                                         recipient_email: management.email),
            t('activities.telco.status_updated.others',
              owner_email: super_user.email,
              recipient_email: management.email,
              status_text: t('activities.deactivated')),
            t('activities.telco.user_invited.recipient',
              owner_email: super_user.email, role: :administrator)
          ]
        )
      end
    end

    context 'as a recipient #management' do
      it 'returns relevant activities' do
        activities, errors = paginated_collection(:activities, query, current_user: management)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_deleted.recipient',
              owner_email: super_user.email),
            t('activities.telco.status_updated.recipient',
              owner_email: super_user.email, status_text: t('activities.deactivated'))
          ]
        )
      end
    end

    context 'as a recipient #kam' do
      it 'returns relevant activities' do
        activities, errors = paginated_collection(:activities, query, current_user: kam)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_updated.recipient',
              owner_email: super_user.email),
            t('activities.telco.role_updated.recipient',
              owner_email: super_user.email, role: :super_user, previous_role: :kam)
          ]
        )
      end
    end

    context 'as a third person' do
      it 'returns relevant activities' do
        activities, errors = paginated_collection(:activities, query, current_user: super_user_a)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_updated.others',
              owner_email: super_user.email, recipient_email: kam.email),
            t('activities.telco.role_updated.others', owner_email: super_user.email, recipient_email: kam.email,
                                                      role: :super_user, previous_role: :kam),
            t('activities.telco.profile_deleted.others', owner_email: super_user.email,
                                                         recipient_email: management.email),
            t(
              'activities.telco.status_updated.others',
              owner_email: super_user.email,
              recipient_email: management.email,
              status_text: t('activities.deactivated')
            ),
            t('activities.telco.user_invited.others', owner_email: super_user.email,
                                                      recipient_email: administrator.email, role: :administrator)
          ]
        )
      end
    end

    context 'as a person not involved and without minimal permissions' do
      it 'returns an empty list' do
        activities, errors = paginated_collection(:activities, query, current_user: kam_a)
        expect(errors).to be_nil
        expect(activities).to be_empty
      end
    end

    context 'with single user id filter' do
      it 'returns logs for the given user' do
        activities, errors = paginated_collection(:activities, query(user_ids: [kam.id]), current_user: super_user)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_updated.owner',
              recipient_email: kam.email),
            t('activities.telco.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam)
          ]
        )
      end
    end

    context 'with multiple user ids in filter' do
      it 'returns logs for given user ids' do
        activities, errors = paginated_collection(
          :activities,
          query(user_ids: [management.id, kam.id]),
          current_user: super_user
        )

        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_updated.owner',
              recipient_email: kam.email),
            t('activities.telco.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam),
            t('activities.telco.profile_deleted.owner',
              recipient_email: management.email),
            t('activities.telco.status_updated.owner',
              recipient_email: management.email, status_text: t('activities.deactivated'))
          ]
        )
      end
    end

    context 'with dates filter' do
      it 'returns logs created in the given date range' do
        activities, errors = paginated_collection(
          :activities,
          query(dates: [1.day.ago.to_s, Time.current.to_s]),
          current_user: super_user
        )

        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam),
            t('activities.telco.profile_deleted.owner',
              recipient_email: management.email),
            t('activities.telco.status_updated.owner',
              recipient_email: management.email, status_text: t('activities.deactivated')),
            t('activities.telco.user_invited.owner',
              recipient_email: administrator.email, role: :administrator)
          ]
        )
      end
    end

    context 'with date filter' do
      it 'returns logs created in the given date' do
        activities, errors = paginated_collection(
          :activities,
          query(dates: [1.day.from_now.to_s]),
          current_user: super_user
        )

        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.profile_updated.owner', recipient_email: kam.email)
          ]
        )
      end
    end

    context 'with actions filter' do
      it 'returns logs matching actions' do
        activities, errors = paginated_collection(
          :activities,
          query(actions: %w[role_updated status_updated]),
          current_user: super_user
        )

        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.telco.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam),
            t('activities.telco.status_updated.owner',
              recipient_email: management.email, status_text: t('activities.deactivated'))
          ]
        )
      end
    end

    context 'with search queries' do
      context 'when queried by recipient email' do
        it 'returns logs matching recipient email' do
          activities, errors = paginated_collection(
            :activities,
            query(query: management.email),
            current_user: super_user
          )

          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.profile_deleted.owner',
                recipient_email: management.email),
              t('activities.telco.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end

      context 'when queried by owner email' do
        it 'returns logs matching owner email' do
          activities, errors = paginated_collection(
            :activities,
            query(query: super_user.email),
            current_user: super_user
          )

          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.profile_updated.owner',
                recipient_email: kam.email),
              t('activities.telco.role_updated.owner',
                recipient_email: kam.email, role: :super_user, previous_role: :kam),
              t('activities.telco.profile_deleted.owner',
                recipient_email: management.email),
              t('activities.telco.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated')),
              t('activities.telco.user_invited.owner',
                recipient_email: administrator.email, role: :administrator)
            ]
          )
        end
      end

      context 'when queried by action' do
        it 'returns logs matching the action' do
          activities, errors = paginated_collection(
            :activities,
            query(query: 'updated'),
            current_user: super_user
          )

          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.profile_updated.owner',
                recipient_email: kam.email),
              t('activities.telco.role_updated.owner',
                recipient_email: kam.email, role: :super_user, previous_role: :kam),
              t('activities.telco.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end

      context 'when queried by role' do
        it 'returns logs matching the role' do
          activities, errors = paginated_collection(
            :activities,
            query(query: 'super_use'), # typo intentional
            current_user: super_user
          )

          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.role_updated.owner',
                recipient_email: kam.email, role: :super_user, previous_role: :kam)
            ]
          )
        end
      end

      # Query for the active text i.e the key and not value.
      #   #=> log_data { parameters: { active: false } }
      context 'when queried by status #key' do
        it 'returns logs matching the status' do
          activities, errors = paginated_collection(:activities, query(query: 'active'),
                                                    current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end

      context 'when queried by user status #value' do
        it 'returns logs matching the status' do
          activities, errors = paginated_collection(:activities, query(query: 'false'),
                                                    current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end

      context 'when queried by projects id' do
        before do
          create(
            :activity,
            owner: super_user,
            trackable: project,
            action: :project_created,
            log_data: {
              owner_email: super_user.email,
              parameters: { entry_type: project.entry_type, project_name: project.name }
            }
          )
        end

        it 'returns logs matching the project id' do
          activities, errors = paginated_collection(:activities, query(query: '22'), current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.project.project_created.owner',
                project_name: project.name)
            ]
          )
        end
      end

      context 'when queried by projects external id' do
        before do
          create(
            :activity,
            owner: super_user,
            trackable: project,
            action: :project_created,
            log_data: {
              owner_email: super_user.email,
              parameters: { entry_type: project.entry_type, project_name: project.name }
            }
          )
        end

        it 'returns logs matching the project external id' do
          activities, errors = paginated_collection(:activities, query(query: project.external_id),
                                                    current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.project.project_created.owner',
                project_name: project.name)
            ]
          )
        end
      end

      context 'when queried by building OS id' do
        before do
          create(
            :activity,
            owner: super_user,
            trackable: building,
            action: :building_created,
            log_data: {
              owner_email: super_user.email,
              parameters: { name: building.name, project_name: building.project_name }
            }
          )
        end

        it 'returns logs matching the building os id' do
          activities, errors = paginated_collection(:activities, query(query: '112233'), current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.projects.building_created.owner',
                name: building.name, project_name: project.name)
            ]
          )
        end
      end
    end

    describe 'performance benchmarks' do
      it 'executes within 30 ms' do
        expect { paginated_collection(:activities, query, current_user: super_user) }.to perform_under(30).ms
      end

      it 'executes n iterations in x seconds', ips: true do
        expect { paginated_collection(:activities, query, current_user: super_user) }.to(
          perform_at_least(perform_atleast).within(perform_within).warmup(warmup_for).ips
        )
      end
    end

    describe 'pagination' do
      context 'with first N filter' do
        it 'returns the first N activities' do
          activities, errors = paginated_collection(:activities, query(first: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.profile_updated.owner',
                recipient_email: kam.email),
              t('activities.telco.role_updated.owner',
                recipient_email: kam.email, role: :super_user, previous_role: :kam)
            ]
          )
        end
      end

      context 'with skip N filter' do
        it 'returns activities after skipping N records' do
          activities, errors = paginated_collection(:activities, query(skip: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.profile_deleted.owner',
                recipient_email: management.email),
              t('activities.telco.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated')),
              t('activities.telco.user_invited.owner',
                recipient_email: administrator.email, role: :administrator)
            ]
          )
        end
      end

      context 'with first N & skip M filter' do
        it 'returns first N activities after skipping M records' do
          activities, errors = paginated_collection(:activities, query(first: 2, skip: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.telco.profile_deleted.owner',
                recipient_email: management.email),
              t('activities.telco.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end
    end
  end

  def query(args = {})
    connection_query("activities#{query_string(args)}", 'id createdAt displayText')
  end
end
