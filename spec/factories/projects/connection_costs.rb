# frozen_string_literal: true

FactoryBot.define do
  factory :projects_connection_cost, class: 'Projects::ConnectionCost' do
    connection_type { 'MyString' }
    standard_cost { false }
    value { 'MyString' }
  end
end
