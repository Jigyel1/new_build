# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::StatusUpdater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: :update_status }) }
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
            'activities.telco.status_updated.owner',
            recipient_email: team_standard.email,
            status_text: t('activities.deactivated')
          )
        )
      end

      it 'keeps track of attribute changes' do
        fields = logidze_fields(User, team_standard.id)
        expect(fields).to have_attributes(active: false)
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
            'activities.telco.status_updated.recipient',
            owner_email: super_user.email,
            status_text: t('activities.deactivated')
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
            'activities.telco.status_updated.others',
            owner_email: super_user.email,
            recipient_email: team_standard.email,
            status_text: t('activities.deactivated')
          )
        )
      end
    end
  end

  def update_query
    <<~GQL
      mutation {
        updateUserStatus(
          input: {
            attributes: {
              id: "#{team_standard.id}"
              active: false
            }
          }
        )
        { user { id active } }
      }
    GQL
  end
end
