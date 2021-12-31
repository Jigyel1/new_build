# frozen_string_literal: true

require 'rails_helper'

describe Projects::BuildCosts::HfcCalculator do
  before_all do
    create(:admin_toolkit_project_cost)
    create(:admin_toolkit_penetration, zip: '8002', rate: 0.3507, kam_region: create(:kam_region))
  end
  let_it_be(:address) { build(:address, zip: '8002') }

  let_it_be(:calculator) do
    described_class.new(
      project: create(:project, apartments_count: 1, address: address),
      project_cost: 6200
    )
  end

  describe '#call' do
    it 'returns hfc build cost for the connection' do
      expect(calculator.call).to eq(6252.605)
    end
  end
end
