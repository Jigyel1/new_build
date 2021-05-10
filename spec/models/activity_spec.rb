# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('Telco::Uam::User') }
    it { is_expected.to belong_to(:recipient).class_name('Telco::Uam::User') }
    it { is_expected.to belong_to(:trackable).optional(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:verb).in_array(Activity::VALID_VERBS)}
    it { is_expected.to validate_presence_of(:trackable_type) }
  end
end
