# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::ImportBuildings, type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :import }) }

  let(:params) do
    {
      operations: {
        query: query,
        variables: { file: nil }
      }.to_json,
      map: { file: ['variables.file'] }.to_json,
      file: fixture_file_upload(Rails.root.join('spec/files/buildings.xlsx'))
    }
  end

  context 'with permissions' do
    before { sign_in(super_user) }

    # Here we will just test that the API is exposed and doesn't throw any error on execution.
    # Details of the buildings import will be tested in `spec/tasks/import_buildings_spec.rb`
    it 'executes successfully' do
      post api_v1_graphql_path, params: params
      expect(status).to eq(200)
      expect(status).to eq(200)
      expect(json.data.importBuildings.status).to be(true)
    end
  end

  context 'without permissions' do
    before { sign_in(create(:user, :manager_commercialization)) }

    it 'forbids action' do
      post api_v1_graphql_path, params: params
      expect(status).to eq(200)
      expect(json.errors).to eq(['Not Authorized'])
    end
  end

  def query
    <<~QUERY
      mutation($file: Upload!) { importBuildings( input: { file: $file } ){ status } }
    QUERY
  end
end
