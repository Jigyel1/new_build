# frozen_string_literal: true

class AdminToolkitPolicy < ApplicationPolicy
  def update?
    user.admin?
  end
end
