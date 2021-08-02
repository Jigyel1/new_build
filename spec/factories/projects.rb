# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { 'MyString' }
    external_id { 'MyString' }
    project_nr { 'MyString' }
    type { '' }
    category { 'MyString' }
    landlord { 'MyString' }
    assignee { nil }
    type { '' }
    construction_type { 'MyString' }
    move_in { '2021-07-27' }
    lot_number { 'MyString' }
    buildings { 1 }
    apartments { '' }
  end
end
