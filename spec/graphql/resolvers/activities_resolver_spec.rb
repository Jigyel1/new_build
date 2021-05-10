# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::ActivitiesResolver do
  include ActivitiesSpecHelper

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:administrator) { create(:user, :administrator) }
  let_it_be(:super_user_a) { create(:user, :super_user) }
  let_it_be(:management) { create(:user, :management) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_a) { create(:user, :kam) }
  before_all { create_activities }

  describe '.resolve' do
    context 'as an owner' do
      it 'returns relevant activities' do
        activities, errors = paginated_collection(:activities, query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.user.profile_updated.owner',
              recipient_email: kam.email),
            t('activities.user.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam),
            t('activities.user.profile_deleted.owner',
              recipient_email: management.email),
            t('activities.user.status_updated.owner',
              recipient_email: management.email, status_text: t('activities.deactivated')),
            t('activities.user.user_invited.owner',
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
            t('activities.user.profile_updated.others',
              owner_email: super_user.email, recipient_email: kam.email),
            t('activities.user.role_updated.others', owner_email: super_user.email, recipient_email: kam.email,
                                                     role: :super_user, previous_role: :kam),
            t('activities.user.profile_deleted.others', owner_email: super_user.email,
                                                        recipient_email: management.email),
            t('activities.user.status_updated.others', owner_email: super_user.email, recipient_email: management.email,
                                                       status_text: t('activities.deactivated')),
            t('activities.user.user_invited.recipient',
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
            t('activities.user.profile_deleted.recipient',
              owner_email: super_user.email),
            t('activities.user.status_updated.recipient',
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
            t('activities.user.profile_updated.recipient',
              owner_email: super_user.email),
            t('activities.user.role_updated.recipient',
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
            t('activities.user.profile_updated.others',
              owner_email: super_user.email, recipient_email: kam.email),
            t('activities.user.role_updated.others', owner_email: super_user.email, recipient_email: kam.email,
                                                     role: :super_user, previous_role: :kam),
            t('activities.user.profile_deleted.others', owner_email: super_user.email,
                                                        recipient_email: management.email),
            t(
              'activities.user.status_updated.others',
              owner_email: super_user.email,
              recipient_email: management.email,
              status_text: t('activities.deactivated')
            ),
            t('activities.user.user_invited.others', owner_email: super_user.email,
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

    context 'with single email filter' do
      it 'returns logs matching given email' do
        activities, errors = paginated_collection(:activities, query(emails: [kam.email]), current_user: super_user)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.user.profile_updated.owner',
              recipient_email: kam.email),
            t('activities.user.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam)
          ]
        )
      end
    end

    context 'with multiple emails in filter' do
      it 'returns logs matching given emails' do
        activities, errors = paginated_collection(:activities, query(emails: [management.email, kam.email]),
                                                  current_user: super_user)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.user.profile_updated.owner',
              recipient_email: kam.email),
            t('activities.user.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam),
            t('activities.user.profile_deleted.owner',
              recipient_email: management.email),
            t('activities.user.status_updated.owner',
              recipient_email: management.email, status_text: t('activities.deactivated'))
          ]
        )
      end
    end

    context 'with dates filter' do
      it 'returns logs created in the given date range' do
        activities, errors = paginated_collection(:activities, query(dates: [Date.yesterday.to_s, Date.current.to_s]),
                                                  current_user: super_user)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.user.role_updated.owner',
              recipient_email: kam.email, role: :super_user, previous_role: :kam),
            t('activities.user.profile_deleted.owner',
              recipient_email: management.email),
            t('activities.user.status_updated.owner',
              recipient_email: management.email, status_text: t('activities.deactivated')),
            t('activities.user.user_invited.owner',
              recipient_email: administrator.email, role: :administrator)
          ]
        )
      end
    end

    context 'with date filter' do
      it 'returns logs created in the given date' do
        activities, errors = paginated_collection(:activities, query(dates: [Date.tomorrow.to_s]),
                                                  current_user: super_user)
        expect(errors).to be_nil
        expect(activities.pluck('displayText')).to eq(
          [
            t('activities.user.profile_updated.owner', recipient_email: kam.email)
          ]
        )
      end
    end

    context 'with search queries' do
      context 'when queried by recipient email' do
        it 'returns logs matching recipient email' do
          activities, errors = paginated_collection(:activities, query(query: management.email),
                                                    current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.user.profile_deleted.owner',
                recipient_email: management.email),
              t('activities.user.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end

      context 'when queried by owner email' do
        it 'returns logs matching owner email' do
          activities, errors = paginated_collection(:activities, query(query: super_user.email),
                                                    current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.user.profile_updated.owner',
                recipient_email: kam.email),
              t('activities.user.role_updated.owner',
                recipient_email: kam.email, role: :super_user, previous_role: :kam),
              t('activities.user.profile_deleted.owner',
                recipient_email: management.email),
              t('activities.user.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated')),
              t('activities.user.user_invited.owner',
                recipient_email: administrator.email, role: :administrator)
            ]
          )
        end
      end

      context 'when queried by verb' do
        it 'returns logs matching the verb' do
          activities, errors = paginated_collection(:activities, query(query: 'updated'),
                                                    current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.user.profile_updated.owner',
                recipient_email: kam.email),
              t('activities.user.role_updated.owner',
                recipient_email: kam.email, role: :super_user, previous_role: :kam),
              t('activities.user.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end

      context 'when queried by role' do
        it 'returns logs matching the role' do
          activities, errors = paginated_collection(:activities, query(query: 'super_use'), # typo intentional
                                                    current_user: super_user)
          expect(errors).to be_nil
          expect(activities.pluck('displayText')).to eq(
            [
              t('activities.user.role_updated.owner',
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
              t('activities.user.status_updated.owner',
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
              t('activities.user.status_updated.owner',
                recipient_email: management.email, status_text: t('activities.deactivated'))
            ]
          )
        end
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        activities#{query_string(args)} {
          totalCount
          edges {
            node { id createdAt displayText }
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

  def query_string(args = {})
    params = args[:emails] ? ["emails: #{args[:emails]}"] : []
    params += ["dates: #{args[:dates]}"] if args[:dates]
    params << "query: \"#{args[:query]}\"" if args[:query]
    params.empty? ? nil : "(#{params.join(',')})"
  end
end
