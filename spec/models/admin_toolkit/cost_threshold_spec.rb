# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::CostThreshold, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:not_exceeding) }
    it { is_expected.to validate_presence_of(:exceeding) }
    it { is_expected.to validate_numericality_of(:not_exceeding).is_greater_than_or_equal_to(0) }
  end
end
