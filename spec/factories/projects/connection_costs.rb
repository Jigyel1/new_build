# frozen_string_literal: true

FactoryBot.define do
  factory :connection_cost, class: 'Projects::ConnectionCost' do
    connection_type { :hfc }
    cost_type { :standard }

    trait :non_standard do
      cost_type { :non_standard }
    end

    trait :too_expensive do
      cost_type { :too_expensive }
    end

    trait :ftth do
      connection_type { :ftth }
    end
  end
end
