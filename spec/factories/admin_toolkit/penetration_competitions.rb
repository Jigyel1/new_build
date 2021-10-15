# frozen_string_literal: true

FactoryBot.define do
  factory :penetration_competition, class: 'AdminToolkit::PenetrationCompetition' do
    penetration { nil }
    competition { nil }
  end
end
