# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Invitation', type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:update_status] }) }
  let_it_be(:params) do
    {
      user: {
        email: 'ym@selise.ch',
        role_id: super_user.role_id,
        profile_attributes: {
          salutation: 'Mr',
          firstname: 'yogesh',
          lastname: 'mongar',
          phone: '+98717857882'
        }
      }
    }
  end
  before_all { post user_invitation_path, params: params, headers: { Authorization: token(super_user) } }

  describe '.activities' do
    let_it_be(:invitee) { User.find_by!(email: 'ym@selise.ch') }

    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.invited.owner',
            recipient_email: invitee.email
          )
        )
      end
    end

    context 'as a recipient' do
      it 'returns activity text in terms of a second person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: invitee)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.invited.recipient',
            owner_email: super_user.email
          )
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.invited.others',
            owner_email: super_user.email,
            recipient_email: invitee.email,
            active: false
          )
        )
      end
    end
  end

  def activities_query
    <<~GQL
      query {
        activities {
          totalCount
          edges {
            node {
              id createdAt displayText
            }
          }
        }
      }
    GQL
  end
end
