# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::OfferContent, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
  end
end
