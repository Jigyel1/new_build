# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::UserDeleter do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:delete] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.activities' do
    before { execute(delete_query, current_user: super_user) }

    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.profile_deleted.owner',
            recipient_email: team_standard.email,
            active: false
          )
        )
      end

      it 'keeps track of attribute changes' do
        fields = logidze_fields(User, team_standard.id, unscoped: true)
        expect(fields.discarded_at).to be_present
      end
    end

    context 'as a recipient' do
      it 'returns activity text in terms of a second person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: team_standard)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.profile_deleted.recipient',
            owner_email: super_user.email,
            active: false
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
            'activities.user.profile_deleted.others',
            owner_email: super_user.email,
            recipient_email: team_standard.email,
            active: false
          )
        )
      end
    end
  end

  def delete_query
    <<~GQL
      mutation {
        deleteUser(
          input: {
            id: "#{team_standard.id}"
          }
        )
        { status }
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
