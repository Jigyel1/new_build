# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_footprint_value, class: 'AdminToolkit::FootprintValue' do
    category { :standard }
  end
end
