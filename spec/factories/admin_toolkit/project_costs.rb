# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_project_cost, class: 'AdminToolkit::ProjectCost' do
    initialize_with { AdminToolkit::ProjectCost.instance }
  end
end
