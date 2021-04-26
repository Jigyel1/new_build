class UserPolicy < ApplicationPolicy
  def index?
    super
  end

  def show?
    own_profile? || super
  end

  def update?
    super
  end

  def delete?
    super
  end

  def update_role?
    super
  end

  def update_status?
    super
  end

  private

  # TODO: Implement comparable <=> for ARs
  def own_profile?
    record.id == current_user.id
  end
end
