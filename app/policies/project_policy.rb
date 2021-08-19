# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    user.admin? || user.kam? || user.manager_nbo_kam?
  end

  def show?
    create? || user.manager_nbo_kam?
  end

  def create?
    user.admin? || user.management? || user.nbo_team? || user.kam? || user.presales?
  end

  def update?
    user.admin? || user == record.assignee
  end

  def import?
    user.admin? || user.management?
  end

  def export?
    index?
  end

  def destroy?
    index?
  end
end
