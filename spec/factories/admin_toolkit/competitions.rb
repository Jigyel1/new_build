FactoryBot.define do
  factory :admin_toolkit_competition, class: 'AdminToolkit::Competition' do
    name { 'FTTH EVU' }
    factor { 0.9 }
    lease_rate { 75 }
    description { 'With only HFC of the EVU (Open Access Layer 1 & 2; tendency rather Salt & Sunrise)' }
  end
end
