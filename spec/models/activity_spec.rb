# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { create(:activity, owner: create(:user, :kam), recipient: create(:user, :kam)) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('Telco::Uam::User') }
    it { is_expected.to belong_to(:recipient).class_name('Telco::Uam::User') }
    it { is_expected.to belong_to(:trackable).optional(true) }
  end

  describe 'validations' do
    it {
      expect(activity).to(
        validate_inclusion_of(:action)
          .in_array(
            Rails.application.config.activity_actions[activity.trackable_type.downcase]
          )
      )
    }

    it { is_expected.to validate_presence_of(:trackable_type) }
  end
end
