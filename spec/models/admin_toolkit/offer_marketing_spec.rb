# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::OfferMarketing, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:activity_name) }
    it { is_expected.to validate_presence_of(:value) }
  end
end
