# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::PctValue, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }

    it do
      subject = create(
        :admin_toolkit_pct_value,
        pct_cost: create(:admin_toolkit_pct_cost),
        pct_month: create(:admin_toolkit_pct_month)
      )

      expect(subject).to validate_uniqueness_of(:status)
        .scoped_to(%i[pct_cost_id pct_month_id])
        .ignoring_case_sensitivity
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:pct_cost) }
    it { is_expected.to belong_to(:pct_month) }
  end
end
