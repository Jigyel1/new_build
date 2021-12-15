# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::OfferAdditionalCost, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:type) }
    # it { is_expected.to validate_numericality_of(:value).is_greater_than_or_equal_to(0) if addition? }
    # it { is_expected.to validate_numericality_of(:value).is_less_than(0) if discount? }
  end
end
