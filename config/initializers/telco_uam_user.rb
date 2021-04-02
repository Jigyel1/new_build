User = Telco::Uam::User

Warden::Manager.after_set_user do |record, warden, options|
  if record && !record.active?
    scope = options[:scope]
    warden.logout(scope)
    throw :warden, scope: scope, message: record.inactive_message
  end
end
