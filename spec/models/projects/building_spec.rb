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
    it do
      building = create(:building, name: 'Burj Khalifa', project: create(:project))
      expect(building).to validate_uniqueness_of(:external_id)
    end
  end

  describe 'date validations' do
    let_it_be(:project) { create(:project) }

    context 'when move in end date is before the start date' do
      subject(:building) do
        build(:building, project: project, move_in_starts_on: Date.current, move_in_ends_on: Date.current.yesterday)
      end

      it 'invalidates record' do
        expect(building).not_to be_valid
        expect(building.errors.full_messages).to eq(
          [
            "Move in ends on #{t('date.errors.messages.must_be_after',
                                 date: building.move_in_starts_on)}"
          ]
        )
      end
    end

    context 'when move in end date equal to the start date' do
      subject(:building) do
        build(:building, project: project, move_in_starts_on: Date.current, move_in_ends_on: Date.current)
      end

      it 'invalidates record' do
        expect(building).not_to be_valid
        expect(building.errors.full_messages).to eq(
          [
            "Move in ends on #{t('date.errors.messages.must_be_after',
                                 date: building.move_in_starts_on)}"
          ]
        )
      end
    end

    context 'when move in end date is after the start date' do
      it do
        expect(
          build(:building, project: project, move_in_starts_on: Date.current, move_in_ends_on: Date.current.tomorrow)
        ).to be_valid
      end
    end
  end

  describe 'callbacks' do
    subject(:building) { create(:building, project: create(:project), apartments_count: 5) }

    it { expect(building.project.apartments_count).to eq(5) }
  end
end
