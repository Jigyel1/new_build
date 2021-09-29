# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::PenetrationCompetition, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:penetration) }
    it { is_expected.to belong_to(:competition) }
  end
end
