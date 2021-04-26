# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authorization context: https://actionpolicy.evilmartians.io/#/authorization_context
  alias_method :current_user, :user

  # match any one or more of a character suffixed with ?
  def method_missing(method_sym, *_args)
    if /^[a-z]+\D[a-z]+[?]$/.match?(method_sym.to_s)
      permission(method_sym.to_s.delete_suffix!('?'))
    else
      super
    end
  end

  def index?
    permission('read')
  end
  alias_method :show?, :index?

  def permission(key)
    role = user.role
    actions(role) && actions(role)[key]
  end

  def actions(accessor)
    klass = record.is_a?(Class) ? record : record.class
    accessor.permissions.find_by(resource: klass.name.demodulize.underscore).try(:actions)
  end
end
