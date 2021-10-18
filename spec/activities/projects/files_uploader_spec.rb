# frozen_string_literal: true

require 'rails_helper'

describe Projects::FilesUploader, type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:super_user_b) { create(:user, :super_user) }

  let_it_be(:params) do
    proc do |attachable_id, attachable_type, query|
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
        attachable_id: attachable_id,
        attachable_type: attachable_type
      }
    end
  end

  let_it_be(:filename) { 'matrix.jpeg' }
  let_it_be(:project_params) { [project.id, 'Project'] }
  let_it_be(:building_params) { [building.id, 'Projects::Building'] }

  before { sign_in(super_user) }

  describe '.activities' do
    context 'with projects' do
      before { post api_v1_graphql_path, params: params.call(*project_params, query(*project_params)) }

      context 'as an owner' do
        it 'returns activity in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.files_uploaded.owner')
          )
        end
      end

      context 'as a general user' do
        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.project.files_uploaded.others',
              owner_email: super_user.email)
          )
        end
      end
    end

    context 'with buildings' do
      before { post api_v1_graphql_path, params: params.call(*building_params, query(*building_params)) }

      context 'as an owner' do
        it 'returns activity in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.files_uploaded.owner')
          )
        end
      end

      context 'as a general user' do
        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.files_uploaded.others',
              owner_email: super_user.email)
          )
        end
      end
    end
  end

  def query(attachable_id, attachable_type)
    <<~QUERY
      mutation($files: [Upload!]!) {
        uploadFiles(
          input: { attributes: { files: $files, attachableId: "#{attachable_id}", attachableType: "#{attachable_type}" }}
        ){
          files { id name size createdAt owner { name } }
        }
      }
    QUERY
  end
end
