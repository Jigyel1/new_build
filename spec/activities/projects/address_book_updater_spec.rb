# frozen_string_literal: true

require 'rails_helper'

describe Projects::AddressBookUpdater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:address_book) { create(:address_book, project: project) }
  let_it_be(:params) { { id: address_book.id, project_id: project.id, name: 'Test', type: :investor } }

  before_all { described_class.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in the first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.address_book_updated.owner',
            project_name: project.name,
            address_book_type: params[:type])
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
          t('activities.projects.address_book_updated.others',
            project_name: project.name,
            address_book_type: params[:type],
            owner_email: super_user.email)
        )
      end
    end
  end
end
