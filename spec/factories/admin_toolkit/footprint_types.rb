# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_footprint_type, class: 'AdminToolkit::FootprintType' do
    provider { :ftth_swisscom }
  end
end
