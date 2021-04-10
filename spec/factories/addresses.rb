# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    street { 'MyString' }
    street_no { 'MyString' }
    city { 'MyString' }
    zip { 'MyString' }
  end
end
