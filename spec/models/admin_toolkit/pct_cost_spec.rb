# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::PctCost, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:min) }
    it { is_expected.to validate_presence_of(:max) }
    it { is_expected.to validate_presence_of(:index) }
    it { is_expected.to validate_uniqueness_of(:index) }

    it { is_expected.to validate_numericality_of(:min).only_integer.is_greater_than_or_equal_to(0) }
    # it { is_expected.to validate_numericality_of(:max).only_integer.is_greater_than_or_equal_to(0) }
    # it { is_expected.to validate_numericality_of(:max).is_greater_than_or_equal_to(:min) }
  end
end
