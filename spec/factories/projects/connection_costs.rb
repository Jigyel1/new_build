# frozen_string_literal: true

FactoryBot.define do
  factory :connection_cost, class: 'Projects::ConnectionCost' do
    connection_type { :hfc }
    cost_type { :standard }
  end
end
