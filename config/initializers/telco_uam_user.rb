# frozen_string_literal: true

Warden::Manager.after_set_user do |record, warden, options|
  if record && !record.active? && !record.discarded?
    scope = options[:scope]
    warden.logout(scope)
    throw :warden, scope: scope, message: record.inactive_message
  end
end
