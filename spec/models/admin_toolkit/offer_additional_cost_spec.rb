# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::OfferAdditionalCost, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:additional_cost_type) }
  end

  describe 'Enum' do
    it { is_expected.to define_enum_for(:additional_cost_type).with_values(%w[discount addition]) }
  end
end
