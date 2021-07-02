FactoryBot.define do
  factory :admin_toolkit_footprint_value, class: 'AdminToolkit::FootprintValue' do
    project_type { :standard }
    footprint_building { nil }
    footprint_type { nil }
  end
end
