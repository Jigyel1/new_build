FactoryBot.define do
  factory :buildings, class: 'Projects::Building' do
    name { "MyString" }
    assignee { nil }
    apartments_count { 1 }
    move_in_starts_on { "2021-08-19" }
    move_in_ends_on { "2021-08-19" }
  end
end
