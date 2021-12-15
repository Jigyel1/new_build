# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::OfferPrice, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:min_apartments) }
    it { is_expected.to validate_presence_of(:max_apartments) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:value) }

    it { is_expected.to validate_numericality_of(:min_apartments).is_greater_than_or_equal_to(0) }
  end
end
