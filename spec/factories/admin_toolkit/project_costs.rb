FactoryBot.define do
  factory :admin_toolkit_project_cost, class: 'AdminToolkit::ProjectCost' do
    standard { 15900 }
    arpu { 56 }
  end
end
