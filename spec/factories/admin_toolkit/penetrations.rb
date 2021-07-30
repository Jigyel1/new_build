# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_penetration, class: 'AdminToolkit::Penetration' do
    zip { Faker::Address.zip }
    city { Faker::Address.city }
    rate { 10.5692 }
    type { :top_city }
    hfc_footprint { false }

    trait :hfc_footprint do
      hfc_footprint { true }
    end

    %i[land agglo med_city].each do |type|
      trait type do
        type { type }
      end
    end

    %i[ftth_sfn f_fast vdsl].each do |competition|
      trait competition do
        after(:build) do |penetration|
          penetration.competition = build(:admin_toolkit_competition, name: competition)
        end
      end
    end

    after(:build) do |penetration|
      penetration.competition = build(:admin_toolkit_competition) unless penetration.competition
    end
  end
end