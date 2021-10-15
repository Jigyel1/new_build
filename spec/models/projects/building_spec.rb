# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::Building, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project).counter_cache(true) }
    it { is_expected.to belong_to(:assignee).required(false) }
    it { is_expected.to have_one(:address) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:address) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }

    it do
      building = create(:building, name: 'Burj Khalifa', project: create(:project))
      expect(building).to validate_uniqueness_of(:external_id)
    end
  end

  describe 'callbacks' do
    subject(:building) { create(:building, project: create(:project), apartments_count: 5) }

    it { expect(building.project.apartments_count).to eq(5) }
  end
end
