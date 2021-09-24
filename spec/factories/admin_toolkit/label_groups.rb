# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_label_group, class: 'AdminToolkit::LabelGroup' do
    code { :technical_analysis }
    name { 'Technical Analysis' }
    label_list { 'Assign KAM, Offer Needed' }

    Project.statuses.each_key do |status|
      trait status do
        name { status.titleize }
        code { status }
      end
    end
  end
end
