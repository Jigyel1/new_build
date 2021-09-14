# frozen_string_literal: true

require_relative '../../app/models/projects/address_book'

FactoryBot.define do
  # by default all projects are `standard`, `proactive`, `reconstruction`
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

    trait :from_info_manager do
      entry_type { :info_manager }
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
