# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  POLICY_ACTION_REGEX = /^[a-z0-9_]+[?]+$/
  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authorization context: https://actionpolicy.evilmartians.io/#/authorization_context

  # match any one or more of a character suffixed with ?
  def method_missing(method_sym, *_args)
    if POLICY_ACTION_REGEX.match?(method_sym.to_s)
      permission(method_sym.to_s.delete_suffix!('?'))
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name =~ POLICY_ACTION_REGEX || super
  end

  def index?
    permission('read')
  end
  alias show? index?

  def create?
    permission('create')
  end

  def permission(key)
    role = user.role
    actions(role) && actions(role)[key]
  end

  def actions(accessor)
    klass = record.is_a?(Class) ? record : record.class
    accessor.permissions.find_by(resource: klass.name.demodulize.underscore).try(:actions)
  end
end
