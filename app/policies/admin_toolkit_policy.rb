# frozen_string_literal: true

class AdminToolkitPolicy < ApplicationPolicy
  # FE needs to internally call most AdminToolkit endpoints during project state transitions.
  # To prevent server from throwing <tt>Not Authorized</tt> exception, allow access to
  # admins and users with project read permission.
  def index?
    user.admin? || begin
      permission = user.permissions.find_by(resource: :project)
      permission && permission.actions['read']
    end
  end

  def create?
    user.admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
