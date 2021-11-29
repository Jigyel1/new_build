# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::ExportBuilding do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, apartments_count: 10, project: project) }

  describe '.resolve' do
    it 'exports the building to CSV' do
      execute(query, current_user: super_user)
      file_path = ActiveStorage::Blob.service.path_for(super_user.building_download.key)
      expect(File.exist?(file_path)).to be(true)
    end
  end

  def query
    <<~GQL
      mutation{
        exportBuilding(input: {
          id: "#{building.id}"
        }){
          url
        }
      }
    GQL
  end
end
