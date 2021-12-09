# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::ExportBuilding do
  include Rails.application.routes.url_helpers

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, apartments_count: 10, project: project) }

  describe '.resolve' do
    it 'exports the building to CSV' do
      response, errors = formatted_response(query, current_user: super_user, key: :exportBuilding)
      expect(errors).to be_nil
      expect(response.url).to eq(url_for(super_user.building_download))
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
