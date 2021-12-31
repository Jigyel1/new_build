# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ConnectionCost, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_one(:pct_cost).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:connection_type) }
    it { is_expected.to validate_presence_of(:cost_type) }
  end
end
