# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::UploadFiles, type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }

  let_it_be(:params) do
    proc do |attachable|
      {
        operations: {
          query: query(attachable),
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
  end

  context 'with permissions' do
    before { sign_in(super_user) }

    it 'updates files for the given resource' do
      post api_v1_graphql_path, params: params.call(building)

      files = json.data.uploadFiles.files
      expect(files.size).to eq(2)
      expect(files.pluck(:name).uniq).to eq(['matrix.jpeg'])
      expect(files.pluck(:size).uniq).to eq([87.64])
      expect(files.pluck(:owner).pluck(:name).uniq).to eq([super_user.name])

      expect(building.files.size).to eq(2)
    end
  end

  context 'without permissions' do
    before { sign_in(create(:user, :manager_commercialization)) }

    it 'forbids action' do
      post api_v1_graphql_path, params: params.call(building)

      expect(json.data.uploadFiles).to be_nil
      expect(json.errors).to eq(['Not Authorized'])
    end
  end

  context 'with attachable as project' do
    before { sign_in(super_user) }
    
    it 'uploads files for the project' do
      post api_v1_graphql_path, params: params.call(project)

      files = json.data.uploadFiles.files
      expect(files.size).to eq(2)
      expect(files.pluck(:name).uniq).to eq(['matrix.jpeg'])
      expect(files.pluck(:size).uniq).to eq([87.64])
      expect(files.pluck(:owner).pluck(:name).uniq).to eq([super_user.name])

      expect(project.files.size).to eq(2)
    end
  end

  def query(attachable)
    <<~QUERY
      mutation($files: [Upload!]!) {
        uploadFiles(
          input: { attributes: { files: $files, attachableId: "#{attachable.id}", attachableType: "#{attachable.class.name}" }}
        )
        { files { id name size createdAt owner { name } } }
      }
    QUERY
  end
end
