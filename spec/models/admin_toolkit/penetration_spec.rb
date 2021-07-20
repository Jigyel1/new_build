# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::Penetration, type: :model do
  describe 'validations' do
    subject(:penetration) { create(:admin_toolkit_penetration) }

    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:zip) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_presence_of(:kam_region) }
    it { is_expected.to validate_presence_of(:competition) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_inclusion_of(:kam_region).in_array(Rails.application.config.kam_regions) }

    it do
      expect(penetration).to validate_uniqueness_of(:zip).ignoring_case_sensitivity
    end

    it do
      expect(penetration).to validate_numericality_of(:rate)
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(100)
    end
  end
end
