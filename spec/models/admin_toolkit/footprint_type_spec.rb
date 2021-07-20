# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::FootprintType, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_uniqueness_of(:index) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:footprint_values) }
  end
end
