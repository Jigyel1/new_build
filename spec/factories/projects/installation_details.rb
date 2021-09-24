# frozen_string_literal: true

FactoryBot.define do
  factory :projects_installation_detail, class: 'Projects::InstallationDetail' do
    project { nil }
    sockets { 1 }
    builder { 'll' }
  end
end
