# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    external_id { SecureRandom.hex }
    category { :standard }
    assignee { nil }
    priority { :proactive }
    construction_type { :reconstruction }
    additional_details { {} }

    transient do
      add_investor { false }
    end

    after(:create) do |project, evaluator|
      project.address_books << build(:address_book, type: :investor) if evaluator.add_investor
    end

    after(:build) do |project|
      project.address = build(:address) unless project.address
    end

    trait :from_info_manager do
      entry_type { :info_manager }
    end

    trait :with_access_tech_cost do
      access_tech_cost { build(:access_tech_cost) }
    end

    trait :with_installation_detail do
      installation_detail { build(:installation_detail) }
    end

    trait :customer_request do
      customer_request { true }
    end

    %w[categories priorities construction_types statuses].each do |key|
      Project.send(key).each_key do |name|
        trait name do
          send(key.singularize) { name }
        end
      end
    end
  end
end
