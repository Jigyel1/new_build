# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:profile).class_name('Telco::Uam::User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:salutation) }
    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to validate_presence_of(:phone) }
  end
end
