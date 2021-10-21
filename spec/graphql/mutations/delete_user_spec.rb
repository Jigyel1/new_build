# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteUser do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: :delete }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    context 'for a valid user' do
      it 'soft deletes the user' do
        response, errors = formatted_response(query(id: team_standard.id), current_user: super_user, key: :deleteUser)
        expect(errors).to be_nil
        expect(response.status).to be(true)

        expect { User.find(team_standard.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { User.unscoped.find(team_standard.id) }.not_to raise_error
        expect(team_standard.reload.discarded_at).to be_present
      end

      it 'resets user email with current time prefixed' do
        response, errors = formatted_response(query(id: team_standard.id), current_user: super_user, key: :deleteUser)
        expect(errors).to be_nil
        expect(response.status).to be(true)

        expect(team_standard.reload.email).to include(Time.current.strftime('%Y_%m_%d_%H_'))
      end
    end

    context 'when user does not exist in the portal' do
      it 'responds with error' do
        response, errors = formatted_response(
          query(id: '16c85b18-473d-4f5d-9ab4-666c7faceb6c\"'), current_user: super_user, key: :deleteUser
        )

        expect(response.status).to be_nil
        expect(errors[0]).to include("Couldn't find Telco::Uam::User with 'id'=16c85b18-473d-4f5d-9ab4-666c7faceb6c\"")
      end
    end

    context 'when deleting your own profile' do
      it 'forbids action' do
        response, errors = formatted_response(query(id: super_user.id), current_user: super_user, key: :deleteUser)
        expect(response.status).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'when deleting an already discarded user' do
      before { team_standard.update_column(:discarded_at, Time.zone.now) }

      it 'responds with error' do
        response, errors = formatted_response(query(id: team_standard.id), current_user: super_user, key: :deleteUser)
        expect(response.status).to be_nil
        expect(errors[0]).to include("Couldn't find Telco::Uam::User with 'id'=#{team_standard.id}")
      end
    end

    context 'when user has associated projects, buildings & tasks' do
      let_it_be(:project_a) { create(:project, assignee: team_standard) }
      let_it_be(:building_a) { create(:building, project: project_a, assignee: team_standard) }
      let_it_be(:project_b) { create(:project, assignee: team_standard, incharge: team_standard) }
      let_it_be(:project_c) { create(:project, incharge: team_standard) }

      let_it_be(:task_a) { create(:task, taskable: project_a, assignee: team_standard, owner: team_standard) }

      context 'without setting an assignee' do
        it 'throws error' do
          response, errors = formatted_response(
            query(id: team_standard.id),
            current_user: super_user,
            key: :deleteUser
          )

          expect(response.status).to be_nil
          expect(errors).to eq([t('user.assignee_missing', records: :tasks)])
        end
      end

      context 'with a valid assignee' do
        it 'updates assignee for all associations' do
          _, errors = formatted_response(
            query(id: team_standard.id, set_assignee: true),
            current_user: super_user,
            key: :deleteUser
          )
          expect(errors).to be_nil

          expect(project_a.reload.assignee_id).to eq(super_user.id)
          expect(building_a.reload.assignee_id).to eq(super_user.id)
          expect(project_b.reload).to have_attributes(assignee_id: super_user.id, incharge_id: super_user.id)
          expect(project_c.reload.incharge_id).to eq(super_user.id)

          expect(task_a.reload).to have_attributes(assignee_id: super_user.id, owner_id: team_standard.id)
        end

        it 'soft deletes the user' do
          response, errors = formatted_response(
            query(id: team_standard.id, set_assignee: true),
            current_user: super_user,
            key: :deleteUser
          )
          expect(errors).to be_nil
          expect(response.status).to be(true)

          expect { User.find(team_standard.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'with associated kam regions' do
      let_it_be(:kam_a) { create(:user, :kam) }
      let_it_be(:kam_b) { create(:user, :kam) }
      let_it_be(:kam_region_a) { create(:kam_region, kam: kam_a) }
      let_it_be(:kam_region_b) { create(:kam_region, name: 'Ticino', kam: kam_b) }
      let_it_be(:kam_region_c) { create(:kam_region, name: 'Romandie', kam: kam_b) }

      context 'with proper region mapping details' do
        it 'reassigns the region to another kam and soft deletes the user' do
          response, errors = formatted_response(
            query(id: kam_b.id, set_region_mapping: true),
            current_user: super_user,
            key: :deleteUser
          )
          expect(errors).to be_nil
          expect(response.status).to be(true)

          expect(kam_region_b.reload.kam_id).to eq(kam_a.id)
          expect(kam_region_c.reload.kam_id).to eq(kam_a.id)
          expect { User.find(kam_b.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'without region mapping details' do
        it 'throws errors' do
          response, errors = formatted_response(
            query(id: kam_b.id),
            current_user: super_user,
            key: :deleteUser
          )
          expect(response.status).to be_nil
          expect(errors).to eq([t('user.kam_with_regions', references: kam_b.kam_regions.pluck(:name).to_sentence)])
        end
      end

      context 'with invalid region mapping details' do
        it 'throws errors' do
          response, errors = formatted_response(
            query(id: kam_b.id, set_region_mapping: true, region_id: kam_region_a.id),
            current_user: super_user,
            key: :deleteUser
          )
          expect(response.status).to be_nil
          expect(errors).to eq([t('user.kam_with_regions',
                                  references: kam_b.reload.kam_regions.pluck(:name).to_sentence)])

          # rollback check
          expect(kam_b.kam_regions.pluck(:id)).to match_array([kam_region_b.id, kam_region_c.id])
        end
      end
    end

    context 'with associated kam investors' do
      let_it_be(:kam_a) { create(:user, :kam) }
      let_it_be(:kam_b) { create(:user, :kam) }
      let_it_be(:kam_investor_a) { create(:kam_investor, kam: kam_a) }
      let_it_be(:kam_investor_b) { create(:kam_investor, kam: kam_b) }
      let_it_be(:kam_investor_c) { create(:kam_investor, kam: kam_b) }

      context 'with proper investor mapping details' do
        it 'reassigns the investor to another kam and soft deletes the user' do
          response, errors = formatted_response(
            query(id: kam_b.id, set_investor_mapping: true),
            current_user: super_user,
            key: :deleteUser
          )
          expect(errors).to be_nil
          expect(response.status).to be(true)

          expect(kam_investor_b.reload.kam_id).to eq(kam_a.id)
          expect(kam_investor_c.reload.kam_id).to eq(kam_a.id)
          expect { User.find(kam_b.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'without investor mapping details' do
        it 'throws errors' do
          response, errors = formatted_response(
            query(id: kam_b.id),
            current_user: super_user,
            key: :deleteUser
          )
          expect(response.status).to be_nil
          expect(errors).to eq([t('user.kam_with_investors',
                                  references: kam_b.kam_investors.pluck(:investor_id).to_sentence)])
        end
      end

      context 'with invalid investor mapping details' do
        it 'throws errors' do
          response, errors = formatted_response(
            query(id: kam_b.id, set_investor_mapping: true, investor_id: kam_investor_a.id),
            current_user: super_user,
            key: :deleteUser
          )
          expect(response.status).to be_nil
          expect(errors).to eq([t('user.kam_with_investors',
                                  references: kam_b.reload.kam_investors.pluck(:investor_id).to_sentence)])

          # rollback check
          expect(kam_b.kam_investors.pluck(:id)).to match_array([kam_investor_b.id, kam_investor_c.id])
        end
      end
    end
  end

  def region_mapping(set_region_mapping, region_id)
    return unless set_region_mapping

    region_id ||= kam_region_c.id

    <<~REGION_MAPPINGS
      regionMappings: [
        { kamRegionId: \"#{kam_region_b.id}\", kamId: \"#{kam_a.id}\" },
        { kamRegionId: \"#{region_id}\", kamId: \"#{kam_a.id}\" }#{' '}
      ]
    REGION_MAPPINGS
  end

  def investor_mapping(set_investor_mapping, investor_id)
    return unless set_investor_mapping

    investor_id ||= kam_investor_c.id

    <<~INVESTOR_MAPPINGS
      investorMappings: [
        { kamInvestorId: \"#{kam_investor_b.id}\", kamId: \"#{kam_a.id}\" },
        { kamInvestorId: \"#{investor_id}\", kamId: \"#{kam_a.id}\" }#{' '}
      ]
    INVESTOR_MAPPINGS
  end

  def assignee(set_assignee)
    return unless set_assignee

    "assigneeId: \"#{super_user.id}\""
  end

  def query(args = {})
    <<~GQL
      mutation {
        deleteUser(
          input: {
            attributes: {
              id: "#{args[:id]}"
              #{assignee(args[:set_assignee])}
              #{region_mapping(args[:set_region_mapping], args[:region_id])}
              #{investor_mapping(args[:set_investor_mapping], args[:investor_id])}
            }
          }
        )
        { status }
      }
    GQL
  end
end
