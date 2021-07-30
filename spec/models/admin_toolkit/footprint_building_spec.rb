# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::FootprintBuilding, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:min) }
    it { is_expected.to validate_presence_of(:max) }
    it { is_expected.to validate_presence_of(:index) }

    it { is_expected.to validate_numericality_of(:min).is_greater_than(0) }

    it do
      subject = create(:admin_toolkit_footprint_building)
      expect(subject).to validate_uniqueness_of(:index)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:footprint_values) }
  end
end
