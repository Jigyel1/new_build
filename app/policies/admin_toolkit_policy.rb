# frozen_string_literal: true

class AdminToolkitPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def update?
    index?
  end
end
