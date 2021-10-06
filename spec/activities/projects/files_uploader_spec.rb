# frozen_string_literal: true

require 'rails_helper'

describe Projects::FilesUploader, type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
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
      files: file_upload,
      attachable_id: building.id,
      attachable_type: 'Projects::Building'
    }
  end

  before do
    sign_in(super_user)
    post api_v1_graphql_path, params: params
  end

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity in terms of first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.project.file_uploaded.owner')
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)

        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.project.file_uploaded.others')
        )
      end
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
