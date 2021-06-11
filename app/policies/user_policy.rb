# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    own_profile? || super
  end

  %i[update_role update_status delete].each do |method|
    define_method "#{method}?" do
      !own_profile? && super(method)
    end
  end

  private

  def own_profile?
    record == user
  end
end
