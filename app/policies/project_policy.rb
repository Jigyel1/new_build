# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
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
