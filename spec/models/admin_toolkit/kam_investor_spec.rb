# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::KamInvestor, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:investor_id) }

    it do
      subject = create(:kam_investor, kam: create(:user, :kam))
      expect(subject).to validate_uniqueness_of(:investor_id).ignoring_case_sensitivity
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:kam) }
  end
end
