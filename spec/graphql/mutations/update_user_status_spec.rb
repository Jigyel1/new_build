# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateUserStatus do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:update_status] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    let!(:params) { { id: team_standard.id, active: false } }

    it 'updates the user status' do
      response, errors = formatted_response(query(params), current_user: super_user, key: :updateUserStatus)
      expect(errors).to be_nil
      expect(response.user.active).to be(false)
    end

    it 'logs the activity' do
      _ = formatted_response(query(params), current_user: super_user, key: :updateUserStatus)
      expect(team_standard.reload.log_data.version).to eq(2)
      expect(team_standard.at(version: 1).active).to be(true)
      expect(team_standard.at(version: 2).active).to be(false)
    end

    describe '.activities' do
      before { execute(query(params), current_user: super_user) }

      context 'as an owner' do
        it 'returns activity text in terms of a first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          activity = activities.first
          expect(activity[:displayText]).to eq(
                                              t(
                                                "activities.user.status_updated.owner",
                                                owner_email: super_user.email,
                                                active: false
                                              )
                                            )
        end
      end

      context 'as a recipient' do
        it 'returns activity text in terms of a second person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: team_standard)
          expect(errors).to be_nil
          activity = activities.first
          expect(activity[:displayText]).to eq(
                                              t(
                                                "activities.user.status_updated.recipient",
                                                recipient_email: team_standard.email,
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
                                                "activities.user.status_updated.others",
                                                email: team_standard.email,
                                                active: false
                                              )
                                            )
        end
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateUserStatus(
          input: {
            attributes: {
              id: "#{args[:id]}"
              active: #{args[:active]}
            }
          }
        )
        { user { id active } }
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
