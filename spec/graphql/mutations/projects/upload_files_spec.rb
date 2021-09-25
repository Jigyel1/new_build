# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::UploadFiles, type: :request do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }

  let_it_be(:params) do
    {
      operations: {
        query: query,
        variables: {
          files: [nil]
        }
      }.to_json,
      map: {
        files: ['variables.files.0', 'variables.files.1']
      }.to_json,
      files: file_upload
    }
  end

  context 'with permissions' do
    before { sign_in(super_user) }

    it 'updates files for the given resource' do
      post api_v1_graphql_path, params: params

      files = json.data.uploadFiles.files
      expect(files.size).to eq(2)
      expect(files.pluck(:name).uniq).to eq(['matrix.jpeg'])
      expect(files.pluck(:size).uniq).to eq([87.64])
      expect(files.pluck(:owner).pluck(:name).uniq).to eq([super_user.name])
    end
  end

  context 'without permissions' do
    before { sign_in(create(:user, :manager_commercialization)) }

    it 'forbids action' do
      post api_v1_graphql_path, params: params

      expect(json.data.uploadFiles).to be_nil
      expect(json.errors).to eq(['Not Authorized'])
    end
  end

  def query
    <<~QUERY
      mutation($files: [Upload!]!) {
        uploadFiles(
          input: { attributes: { files: $files, attachableId: "#{building.id}", attachableType: "Projects::Building" }}
        ){
          files { id name size createdAt owner { name } }
        }
      }
    QUERY
  end
end
