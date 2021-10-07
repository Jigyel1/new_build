# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_footprint_apartment, class: 'AdminToolkit::FootprintApartment' do
    min { 1 }
    max { 5 }
    index { 0 }
  end
end
