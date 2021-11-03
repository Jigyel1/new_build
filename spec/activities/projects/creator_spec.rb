# frozen_string_literal: true

require 'rails_helper'

describe Projects::Creator do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :create }) }
  let_it_be(:params) do
    {
      name: 'tashi dorji',
      buildings_count: 12,
      apartments_count: 12,
      address_attributes: {
        zip: '123',
        street: Faker::Address.street_name.to_s,
        street_no: Faker::Address.building_number.to_s,
        city: Faker::Address.city.to_s
      },
      address_books_attributes: [{
        type: 'Investor',
        name: 'Philips',
        additional_name: 'Jordan',
        company: 'Charlotte Hornets',
        language: 'D',
        phone: '099292922',
        mobile: '03393933',
        email: 'philips.jordan@chornets.us',
        website: 'charlotte-hornets.com'
      }],
      entry_type: :manual
    }
  end
  before_all { ::Projects::Creator.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in the first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.project.project_created.owner',
            project_name: params[:name])
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
          t('activities.project.project_created.others',
            project_name: params[:name],
            entry_type: params[:entry_type],
            owner_email: super_user.email)
        )
      end
    end
  end
end
