# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    actor { nil }
    object { nil }
    verb { 'MyString' }
  end
end
