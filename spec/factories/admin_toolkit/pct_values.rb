# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_pct_value, class: 'AdminToolkit::PctValue' do
    status { :prio_one }
  end
end
