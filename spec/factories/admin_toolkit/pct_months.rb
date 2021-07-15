# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_pct_month, class: 'AdminToolkit::PctMonth' do
    index { 0 }
    min { 1 }
    max { 12 }
    header { 'Less than 12 months' }
  end
end
