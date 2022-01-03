# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::Competition, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:factor) }
    it { is_expected.to validate_presence_of(:lease_rate) }
    it { is_expected.to validate_numericality_of(:factor).is_greater_than_or_equal_to(0) }

    it do
      expect(create(:admin_toolkit_competition)).to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end
  end

  describe 'Enum' do
    subject(:competition) { described_class.new }

    it do
      expect(competition).to define_enum_for(:calculation_type).with_values(
        dsl: 'Swisscom DSL',
        ftth: 'Swisscom FTTH',
        sfn: 'SFN/Big4'
      ).backed_by_column_of_type(:string)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:projects).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:penetration_competitions) }
    it { is_expected.to have_many(:penetrations).through(:penetration_competitions).dependent(:restrict_with_error) }
  end
end
