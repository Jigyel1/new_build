# frozen_string_literal: true

FactoryBot.define do
  factory :address_book, class: 'Projects::AddressBook' do
    name { 'MyString' }
    type { :investor }
    additional_name { 'MyString' }
    company { 'MyString' }
    po_box { 'MyString' }
    language { 'D' }
    phone { 'MyString' }
    mobile { 'MyString' }
    email { 'MyString' }
    website { 'MyString' }
    project { nil }
  end
end
