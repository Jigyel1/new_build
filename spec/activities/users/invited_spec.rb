# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Invitation', type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: :update_status }) }
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

  before { post user_invitation_path, params: params, headers: { Authorization: token(super_user) } }

  describe '.activities' do
    let(:invitee) { User.find_by!(email: 'ym@selise.ch') }

    context 'as an owner' do
      it 'returns activities in first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.telco.user_invited.owner',
            recipient_email: invitee.email,
            role: role_name(invitee.role_name)
          )
        )
      end

      it 'keeps track of attribute changes' do
        fields = logidze_fields(User, invitee.id)
        expect(fields).to have_attributes(
          email: invitee.email,
          active: true,
          role_id: invitee.role_id
        )
        expect(fields.invitation_created_at).to be_present
      end
    end

    context 'as a recipient' do
      it 'returns activities in second person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: invitee)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.telco.user_invited.recipient',
            owner_email: super_user.email,
            role: role_name(invitee.role_name)
          )
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activities in third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.telco.user_invited.others',
            owner_email: super_user.email,
            recipient_email: invitee.email,
            role: role_name(invitee.role_name)
          )
        )
      end
    end
  end
end
