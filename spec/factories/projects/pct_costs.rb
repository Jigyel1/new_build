FactoryBot.define do
  factory :projects_pct_cost, class: 'Projects::PctCost' do
    project_cost { "9.99" }
    socket_installation_cost { "9.99" }
    arpu { "9.99" }
    penetration_rate { "9.99" }
    lease_cost { "9.99" }
    penetration_rate { 1.5 }
    payback_period { "MyString" }
  end
end
