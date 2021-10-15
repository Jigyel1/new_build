# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::AccessTechCost, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:hfc_on_premise_cost) }
    it { is_expected.to validate_presence_of(:hfc_off_premise_cost) }
    it { is_expected.to validate_presence_of(:lwl_on_premise_cost) }
    it { is_expected.to validate_presence_of(:lwl_off_premise_cost) }
  end
end
