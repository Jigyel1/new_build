# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::RoleResolver do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { role: :read }) }
  let_it_be(:user_role) { super_user.role }

  describe '.resolve' do
    it 'returns current user details' do
      role, errors = formatted_response(query(id: user_role.id), current_user: super_user, key: :role)
      expect(errors).to be_nil
      expect(role).to have_attributes(
        id: role.id,
        name: role.name
      )
    end

    context "when record doesn't exist" do
      it 'responds with error' do
        data, errors = formatted_response(
          query(id: '16c85b18-473d-4f5d-9ab4-666c7faceb6c\"'), current_user: super_user
        )

        expect(data.role).to be_nil
        expect(errors[0]).to include("Couldn't find Role with 'id'=16c85b18-473d-4f5d-9ab4-666c7faceb6c\"")
      end
    end

    context 'without read permission' do
      let(:team_expert) { create(:user, :team_expert) }

      it 'forbids action' do
        data, errors = formatted_response(query(id: user_role.id), current_user: team_expert)
        expect(data.role).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        role#{query_string(args)} {
          id
          name
        }
      }
    GQL
  end

  def query_string(args = {})
    args[:id].present? ? "(id: \"#{args[:id]}\")" : nil
  end
end
