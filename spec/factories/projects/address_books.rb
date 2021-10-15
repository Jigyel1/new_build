# frozen_string_literal: true

FactoryBot.define do
  factory :address_book, class: 'Projects::AddressBook' do
    name { Faker::Job.title }
    type { :investor }
    main_contact { false }
    entry_type { :manual }

    trait :main_contact do
      main_contact { true }
    end
  end
end
