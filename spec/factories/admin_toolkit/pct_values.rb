# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_pct_value, class: 'AdminToolkit::PctValue' do
    status { :prio_one }

    trait :prio_two do
      status { :prio_two }
    end

    trait :on_hold do
      status { :on_hold }
    end
  end
end
