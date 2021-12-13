# frozen_string_literal: true

require 'rails_helper'

describe Mutations::AdminToolkit::ImportPenetrations, type: :request do
  before_all do
    ['FTTH SC & EVU', 'FTTH SC', 'FTTH EVU', 'G.fast', 'VDSL', 'FTTH Swisscom', 'FTTH SFN', 'f.fast'].each do |name|
      create(:admin_toolkit_competition, name: name)
    end

    Rails.application.config.kam_regions.each do |name|
      create(:kam_region, name: name)
    end
  end

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }

  let(:params) do
    {
      operations: {
        query: query,
        variables: { file: nil }
      }.to_json,
      map: { file: ['variables.file'] }.to_json,
      file: fixture_file_upload(Rails.root.join('spec/files/penetrations.xlsx'))
    }
  end

  context 'with permissions' do
    before { sign_in(super_user) }

    # Here we will just test that the API is exposed and doesn't throw any error on execution.
    # Details of the Penetrations import will be tested in `spec/tasks/penetrations_importer_spec.rb`
    it 'executes successfully' do
      post api_v1_graphql_path, params: params
      expect(status).to eq(200)
      expect(json.data.importPenetrations.status).to be(true)
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
      mutation($file: Upload!) {
        importPenetrations( input: { file: $file } ){
          status
        }
      }
    QUERY
  end
end
