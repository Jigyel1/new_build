# frozen_string_literal: true

FactoryBot.define do
  factory :connection_cost, class: 'Projects::ConnectionCost' do
    connection_type { 'HFC' }
    standard_cost { false }
    value { 194.77 }
  end
end
