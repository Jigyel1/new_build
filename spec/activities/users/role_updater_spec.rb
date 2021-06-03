# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RoleUpdater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:update_role] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.activities' do
    before { execute(update_query, current_user: super_user) }

    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.role_updated.owner',
            recipient_email: team_standard.email,
            role: role_name(super_user.role_name),
            previous_role: role_name(team_standard.role_name)
          )
        )
      end

      it 'keeps track of attribute changes' do
        fields = logidze_fields(User, team_standard.id)
        expect(fields).to have_attributes(role_id: super_user.role_id)
      end

      it 'checks for duplicate activities before creation' do
        execute(update_query, current_user: super_user)
        expect(Activity.pluck(:action).size).to eq(1)
      end
    end

    context 'as a recipient' do
      it 'returns activity text in terms of a second person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: team_standard)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.role_updated.recipient',
            owner_email: super_user.email,
            role: role_name(super_user.role_name),
            previous_role: role_name(team_standard.role_name)
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
            'activities.user.role_updated.others',
            owner_email: super_user.email,
            recipient_email: team_standard.email,
            role: role_name(super_user.role_name),
            previous_role: role_name(team_standard.role_name)
          )
        )
      end
    end
  end

  def update_query
    <<~GQL
      mutation {
        updateUserRole(
          input: {
            attributes: {
              id: "#{team_standard.id}"
              roleId: "#{super_user.role_id}"
            }
          }
        )
        { user { id roleId } }
      }
    GQL
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
