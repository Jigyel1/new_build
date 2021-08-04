FactoryBot.define do
  factory :projects_address_book, class: 'Projects::AddressBook' do
    name { "MyString" }
    additional_name { "MyString" }
    company { "MyString" }
    po_box { "MyString" }
    language { "MyString" }
    phone { "MyString" }
    mobile { "MyString" }
    email { "MyString" }
    website { "MyString" }
    project { nil }
  end
end
