# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    user.admin? || user.kam? || user.manager_nbo_kam?
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def import?
    index?
  end

  def destroy?
    index?
  end
end
