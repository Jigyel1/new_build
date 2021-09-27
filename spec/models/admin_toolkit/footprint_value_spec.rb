# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::FootprintValue, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:category) }

    it do
      subject = create(
        :admin_toolkit_footprint_value,
        footprint_building: create(:admin_toolkit_footprint_building),
        footprint_type: create(:admin_toolkit_footprint_type)
      )

      expect(subject).to validate_uniqueness_of(:category)
        .scoped_to(%i[footprint_building_id footprint_type_id])
        .ignoring_case_sensitivity
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:footprint_building) }
    it { is_expected.to belong_to(:footprint_type) }
  end
end
