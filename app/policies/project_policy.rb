# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    user.admin? || user.kam? || user.manager_nbo_kam?
  end

  # FIXME: Based on project category - access will be different!
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

  def to_technical_analysis?
    state_admins = user.admin? || user.management? || user.presales? || user.manager_presales?

    if record.standard?
      state_admins || user.team_expert? || user.manager_nbo_kam?
    elsif record.complex?
      state_admins
    end
  end
  alias_method :to_technical_analysis_completed?, :to_technical_analysis?

  def to_archived?
    user.management?
  end
end
