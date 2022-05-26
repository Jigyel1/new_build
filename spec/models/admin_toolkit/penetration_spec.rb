# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::Penetration, type: :model do
  describe 'validations' do
    subject(:penetration) { create(:admin_toolkit_penetration, kam_region: kam_region) }

    let(:kam_region) { create(:kam_region) }

    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:zip) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_presence_of(:type) }

    it do
      expect(penetration).to validate_uniqueness_of(:zip).ignoring_case_sensitivity
    end

    it do
      expect(penetration).to validate_numericality_of(:rate)
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(1)
    end
  end

  describe 'enums' do
    it do
      expect(subject).to define_enum_for(:type).with_values( # rubocop:disable RSpec/NamedSubject
        top_city: 'Top City',
        land: 'Land',
        agglo: 'Agglo',
        med_city: 'Med City'
      ).backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:strategic_partner).with_values( # rubocop:disable RSpec/NamedSubject
        cable_group: 'Cable Group',
        isen_tiefbau: 'Isen Tiefbau',
        cablex_zh: 'Cablex ZH',
        cablex_romandie: 'Cablex Romandie',
        cablex_ticino: 'Cablex Ticino'
      ).backed_by_column_of_type(:string)
    end
  end
end
