# frozen_string_literal: true

FactoryBot.define do
  factory :task, class: 'Projects::Task' do
    taskable { nil }
    title { Faker::Lorem.sentence }
    status { :to_do }
    description { Faker::Lorem.sentence }
    due_date { Date.current }

    Projects::Task.statuses.each_key do |status|
      trait status do
        status { status }
      end
    end

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
