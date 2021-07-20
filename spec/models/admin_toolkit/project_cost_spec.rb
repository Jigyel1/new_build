# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::ProjectCost, type: :model do
  describe 'validations' do
    subject(:instance) { described_class.instance }

    it { is_expected.to validate_presence_of(:index) }
    it { is_expected.to validate_inclusion_of(:index).in_array([0]) }
  end
end
