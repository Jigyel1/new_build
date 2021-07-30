# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::KamRegion, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:name).in_array(Rails.application.config.kam_regions) }

    it do
      subject = create(:admin_toolkit_competition)
      expect(subject).to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:kam).optional(true) }
  end
end
