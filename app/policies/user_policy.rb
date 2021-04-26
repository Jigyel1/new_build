# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    own_profile? || super
  end

  %i[update delete update_role update_status].each do |method|
    define_method "#{method}?" do
      super(method)
    end
  end

  private

  # TODO: Implement comparable <=> for ARs
  def own_profile?
    record.id == current_user.id
  end
end
