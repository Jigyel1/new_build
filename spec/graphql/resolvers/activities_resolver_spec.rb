# frozen_string_literal: true

require 'rails_helper'

module ActivitiesSpecHelper
  def create_activities # rubocop:disable Metrics/AbcSize
    log_data = { owner_email: super_user.email, recipient_email: administrator.email }
    create(:activity, :yesterday, owner: super_user, recipient: administrator, verb: :user_invited, log_data: log_data)

    log_data = { owner_email: super_user.email, recipient_email: management.email, parameters: { active: false } }
    create(:activity, owner: super_user, recipient: management, verb: :status_updated, log_data: log_data)

    log_data = { owner_email: super_user.email, recipient_email: management.email }
    create(:activity, owner: super_user, recipient: management, verb: :profile_deleted, log_data: log_data)

    log_data = { owner_email: super_user.email, recipient_email: kam.email, parameters: { role: :super_user } }
    create(:activity, owner: super_user, recipient: kam, verb: :role_updated, log_data: log_data)

    log_data = { owner_email: super_user.email, recipient_email: kam.email }
    create(:activity, :tomorrow, owner: super_user, recipient: kam, verb: :profile_updated, log_data: log_data)
  end
end

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
            t('activities.user.profile_updated.owner', recipient_email: kam.email),
            t('activities.user.role_updated.owner', recipient_email: kam.email, role: :super_user),
            t('activities.user.profile_deleted.owner', recipient_email: management.email),
            t('activities.user.status_updated.owner', recipient_email: management.email, active: false),
            t('activities.user.user_invited.owner', recipient_email: administrator.email)
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
            t('activities.user.profile_updated.others', owner_email: super_user.email, recipient_email: kam.email),
            t('activities.user.role_updated.others', owner_email: super_user.email, recipient_email: kam.email,
                                                     role: :super_user),
            t('activities.user.profile_deleted.others', owner_email: super_user.email,
                                                        recipient_email: management.email),
            t('activities.user.status_updated.others', owner_email: super_user.email, recipient_email: management.email,
                                                       active: false),
            t('activities.user.user_invited.recipient', owner_email: super_user.email)
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
            t('activities.user.profile_deleted.recipient', owner_email: super_user.email),
            t('activities.user.status_updated.recipient', owner_email: super_user.email, active: false)
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
            t('activities.user.profile_updated.recipient', owner_email: super_user.email),
            t('activities.user.role_updated.recipient', owner_email: super_user.email, role: :super_user)
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
            t('activities.user.profile_updated.others', owner_email: super_user.email, recipient_email: kam.email),
            t('activities.user.role_updated.others', owner_email: super_user.email, recipient_email: kam.email,
                                                     role: :super_user),
            t('activities.user.profile_deleted.others', owner_email: super_user.email,
                                                        recipient_email: management.email),
            t('activities.user.status_updated.others', owner_email: super_user.email,
                                                       recipient_email: management.email, active: false),
            t('activities.user.user_invited.others', owner_email: super_user.email,
                                                     recipient_email: administrator.email)
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
            t('activities.user.profile_updated.owner', recipient_email: kam.email),
            t('activities.user.role_updated.owner', recipient_email: kam.email, role: :super_user)
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
            t('activities.user.profile_updated.owner', recipient_email: kam.email),
            t('activities.user.role_updated.owner', recipient_email: kam.email, role: :super_user),
            t('activities.user.profile_deleted.owner', recipient_email: management.email),
            t('activities.user.status_updated.owner', recipient_email: management.email, active: false)
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
            t('activities.user.role_updated.owner', recipient_email: kam.email, role: :super_user),
            t('activities.user.profile_deleted.owner', recipient_email: management.email),
            t('activities.user.status_updated.owner', recipient_email: management.email, active: false),
            t('activities.user.user_invited.owner', recipient_email: administrator.email)
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
    params.empty? ? nil : "(#{params.join(',')})"
  end
end
