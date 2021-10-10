# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::Penetration, type: :model do
  describe 'validations' do
    subject(:penetration) { create(:admin_toolkit_penetration, kam_region: kam_region) }

    let(:kam_region) { create(:kam_region) }

    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:zip) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_presence_of(:type) }

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
