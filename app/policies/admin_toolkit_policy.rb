# frozen_string_literal: true

class AdminToolkitPolicy < ApplicationPolicy
  # FE needs to internally call some endpoints like <tt>label_groups, project_cost, pcts</tt>
  # for project based calculations. Keep these endpoints accessible to admins and users with
  # project read permission.
  def project_read?
    user.admin? || user.permissions.find_by(actions: { read: true })
  end

  def index?
    user.admin?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end
end
