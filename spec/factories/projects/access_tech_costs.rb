# frozen_string_literal: true

FactoryBot.define do
  factory :access_tech_cost, class: 'Projects::AccessTechCost' do
    hfc_on_premise_cost { '9.99' }
    hfc_off_premise_cost { '9.99' }
    lwl_on_premise_cost { '9.99' }
    lwl_off_premise_cost { '9.99' }
    project { nil }
  end
end