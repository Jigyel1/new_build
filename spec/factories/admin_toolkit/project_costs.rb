# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_project_cost, class: 'AdminToolkit::ProjectCost' do
    standard { 15_900 }
    arpu { 56 }
  end
end
