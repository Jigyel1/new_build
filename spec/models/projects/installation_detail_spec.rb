# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::InstallationDetail, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'enums' do
    it do
      expect(subject).to define_enum_for(:builder) # rubocop:disable RSpec/NamedSubject
        .with_values(ll: 'LL', sunrise_upc: 'Sunrise UPC')
        .backed_by_column_of_type(:string)
    end
  end
end
