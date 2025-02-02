# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::OfferAdditionalCost, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:additional_cost_type) }
  end

  describe 'Enum' do
    subject(:additional_offer_cost) { described_class.new }

    it do
      expect(additional_offer_cost).to define_enum_for(:additional_cost_type).with_values(
        discount: 'Discount',
        addition: 'Addition'
      ).backed_by_column_of_type(:string)
    end
  end
end
