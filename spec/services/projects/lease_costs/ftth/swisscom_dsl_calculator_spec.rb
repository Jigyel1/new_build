# frozen_string_literal: true

require 'rails_helper'

describe Projects::LeaseCosts::Ftth::SwisscomDslCalculator do
  before_all { create(:admin_toolkit_penetration, zip: '8002', rate: 0.3507, kam_region: create(:kam_region)) }

  let_it_be(:project_cost) { create(:admin_toolkit_project_cost) }
  let_it_be(:address) { build(:address, zip: '8002') }

  let_it_be(:calculator) do
    described_class.new(
      project: create(:project, apartments_count: 1, address: address),
      project_cost: 11_200
    )
  end

  describe '#call' do
    it 'returns ftth lease cost for the connection' do
      expect(calculator.call).to eq(1683.36)
    end
  end
end
