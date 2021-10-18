# frozen_string_literal: true

require 'rails_helper'

describe Projects::FilesUploader, type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }

  let_it_be(:params) do
    {
      operations: {
        query: query_project,
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

  let_it_be(:params_b) do
    {
      operations: {
        query: query_project_building,
        variables: {
          files: [nil]
        }
      }.to_json,
      map: {
        files: ['variables.files.0', 'variables.files.1']
      }.to_json,
      files: file_upload,
      attachable_id: project.id,
      attachable_type: 'Project'
    }
  end
  let_it_be(:filename) { params[:files].original_filename }

  before { sign_in(super_user) }

  describe '.activities' do
    context 'with building' do
      before { post api_v1_graphql_path, params: params }

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
        let!(:super_user_b) { create(:user, :super_user) }

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

    context 'with Project' do
      before { post api_v1_graphql_path, params: params_b }

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
        let!(:super_user_b) { create(:user, :super_user) }

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

  def query_project
    <<~QUERY
      mutation($files: [Upload!]!) {
        uploadFiles(
          input: { attributes: { files: $files, attachableId: "#{project.id}", attachableType: "Project" }}
        ){
          files { id name size createdAt owner { name } }
        }
      }
    QUERY
  end

  def query_project_building
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
