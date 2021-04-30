# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    resource { :user }
    actions { { read: true } }
  end
end
