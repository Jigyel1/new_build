# frozen_string_literal: true

require 'byebug'

FactoryBot.define do
  # by default all projects are `standard`, `proactive`, `reconstruction`
  factory :project do
    name { Faker::Lorem.word }
    external_id { SecureRandom.hex }
    project_nr { 'MyString' }
    category { :standard }
    assignee { nil }
    type { :proactive }
    construction_type { :reconstruction }
    lot_number { 'MyString' }
    buildings { 1 }
    apartments { '' }

    %w[categories types construction_types].each do |key|
      Project.send(key).each_key do |name|
        trait name do
          send(key.singularize) {  name }
        end
      end
    end
  end
end
