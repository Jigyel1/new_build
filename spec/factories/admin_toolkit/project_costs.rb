# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_project_cost, class: 'AdminToolkit::ProjectCost' do
    initialize_with { AdminToolkit::ProjectCost.instance }

    socket_installation_rate { 90.55 }
    standard_connection_cost { 399.40 }
    arpu { 45.66 }
  end
end
