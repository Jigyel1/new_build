# frozen_string_literal: true

require 'rails_helper'
# require_relative '../../support/ips_helper'

RSpec.describe Resolvers::ProjectsResolver do
  # include IpsHelper

  let_it_be(:super_user) { create(:user, :super_user) }

  let_it_be(:address_a) { build(:address, street: 'Sharell Meadows', city: 'New Murray', zip: '16564') }
  let_it_be(:project_a) { create(:project, address: address_a) }

  let_it_be(:address_b) { build(:address, street: 'Keenan Parkway', city: 'Andrealand', zip: '58710') }
  let_it_be(:project_b) { create(:project, address: address_b) }

  let_it_be(:address_c) { build(:address, street: 'Block Plains', city: 'Anastasiabury', zip: '47736') }
  let_it_be(:project_c) { create(:project, address: address_c) }

  describe '.resolve' do
    context 'without filters' do
      it 'returns all projects' do
        projects, errors = paginated_collection(:projects, query, current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_b.id, project_c.id])
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        projects#{query_string(args)} {
          totalCount
          edges {
            node { id name }
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

  def query_string(args = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    params = args[:role_ids] ? ["roleIds: #{args[:role_ids]}"] : []
    # params << "departments: #{args[:departments]}" if args[:departments].present?
    # params << "active: #{args[:active]}" unless args[:active].nil?
    # params << "query: \"#{args[:query]}\"" if args[:query]
    # params << "first: #{args[:first]}" if args[:first]
    # params << "skip: #{args[:skip]}" if args[:skip]

    params.empty? ? nil : "(#{params.join(',')})"
  end
end
