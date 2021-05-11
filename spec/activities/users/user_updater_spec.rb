# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::UserUpdater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:update] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }
  let_it_be(:address) { create(:address, addressable: team_standard) }

  describe '.activities' do
    before { execute(update_query, current_user: super_user) }

    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t(
            'activities.user.profile_updated.owner',
            recipient_email: team_standard.email,
            active: false
          )
        )
      end

      it 'keeps track of attribute changes' do
        fields = logidze_fields(Profile, team_standard.profile_id)
        expect(fields).to have_attributes(
          firstname: 'Matt',
          lastname: 'Swanson'
        )

        fields = logidze_fields(Address, team_standard.address.id)
        expect(fields).to have_attributes(street_no: 8008)
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
            'activities.user.profile_updated.recipient',
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
            'activities.user.profile_updated.others',
            owner_email: super_user.email,
            recipient_email: team_standard.email,
            active: false
          )
        )
      end
    end
  end

  def update_query
    profile = <<~PROFILE
      {
        id: "#{team_standard.profile_id}"
        salutation: "mr"
        firstname: "Matt"
        lastname: "Swanson"
      }
    PROFILE

    address = <<~ADDRESS
      {
        id: "#{team_standard.address_id}"
        streetNo: "8008"
      }
    ADDRESS

    <<~GQL
      mutation {
        updateUser(
          input: {
            attributes: {
              id: "#{team_standard.id}"
              profile: #{profile}
              address: #{address}
            }
          }
        )
        { user { id email profile { salutation firstname lastname } address { streetNo } } }
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
