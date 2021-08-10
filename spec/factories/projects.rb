# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    external_id { SecureRandom.hex }
    project_nr { 'MyString' }
    category { :standard }
    assignee { nil }
    type { :proactive }
    construction_type { 'MyString' }
    lot_number { 'MyString' }
    buildings { 1 }
    apartments { '' }
  end
end
