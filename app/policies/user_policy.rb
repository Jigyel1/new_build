class UserPolicy < ApplicationPolicy
  def index?
    super
  end

  def show?
    own_profile? || super
  end

  private

  def own_profile?
    record.id == current_user.id
  end
end
