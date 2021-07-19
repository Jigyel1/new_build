FactoryBot.define do
  factory :admin_toolkit_kam_mapping, class: 'AdminToolkit::KamMapping' do
    kam { nil }
    investor_id { "MyString" }
    investor_description { "MyText" }
  end
end
