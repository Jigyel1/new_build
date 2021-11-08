# frozen_string_literal: true

require 'rails_helper'

describe Projects::FileUpdater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project, files: [file_upload]) }
  let_it_be(:building) { create(:building, project: project, files: [file_upload]) }
  let_it_be(:super_user_b) { create(:user, :super_user) }

  describe '.activities' do
    context 'with projects' do
      let_it_be(:file) { project.files.first }
      let_it_be(:params) { { id: file.id, name: 'project-offer.pdf' } }
      before { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activities in first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_updated.owner',
              filename: 'project-offer.pdf',
              type: 'Project')
          )
        end
      end

      context 'as a general user' do
        it 'returns activities in third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_updated.others',
              filename: 'project-offer.pdf',
              type: 'Project',
              owner_email: super_user.email)
          )
        end
      end
    end

    context 'with buildings' do
      let_it_be(:file) { building.files.first }
      let_it_be(:params) { { id: file.id, name: 'building-contract.pdf' } }
      before { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activities in first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_updated.owner',
              filename: 'building-contract.pdf',
              type: 'Building')
          )
        end
      end

      context 'as a general user' do
        it 'returns activities in third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_updated.others',
              filename: 'building-contract.pdf',
              type: 'Building',
              owner_email: super_user.email)
          )
        end
      end
    end
  end
end
