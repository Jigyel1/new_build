# frozen_string_literal: true

namespace :permission do
  desc 'Updates the permission w.r.t to permission.yml file'
  task update: :environment do
    Role.names.each_key do |name|
      role = Role.find_or_create_by!(name: name)

      Rails.application.config.role_permissions[role.name].each_pair do |resource, actions|
        role.permissions.find_by!(resource: resource).update!(actions: actions.index_with { |_item| true })
      end
    end
  end
end
