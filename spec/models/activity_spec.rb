# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  let_it_be(:kam) { create(:user, :kam) }
  subject(:activity) do
    create(:activity,
           owner: create(:user, :kam),
           recipient: kam ,
           trackable: kam
    )
  end

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('Telco::Uam::User') }
    it { is_expected.to belong_to(:recipient).class_name('Telco::Uam::User').optional(true) }
  end

  describe 'validations' do
    it do
      expect(activity).to(
        validate_inclusion_of(:action)
          .in_array(
            Rails.application.config.activity_actions[activity.trackable_type.underscore]
          )
      )
      end
  end
end
