# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::PctCost, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:connection_cost) }
  end
end
