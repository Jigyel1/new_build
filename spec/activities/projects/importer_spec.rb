# frozen_string_literal: true

require 'rails_helper'

describe Projects::Importer, type: :request do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :import }) }

  let!(:params) do
    {
      operations: {
        query: query,
        variables: { file: nil }
      }.to_json,
      map: { file: ['variables.file'] }.to_json,
      file: fixture_file_upload(Rails.root.join('spec/files/projects.xlsx'))
    }
  end

  before do
    sign_in(super_user)
    post api_v1_graphql_path, params: params
  end

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.project.project_imported.owner',
            filename: 'projects.xlsx')
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activities in third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.project.project_imported.others',
            filename: 'projects.xlsx',
            owner_email: super_user.email)
        )
      end
    end
  end

  def query
    <<~QUERY
      mutation($file: Upload!) {
        importProjects( input: { file: $file } ){
          status
        }
      }
    QUERY
  end
end
