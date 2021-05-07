# frozen_string_literal: true

module Permissions
  class PermissionFinder
    include Assigner
    attr_accessor :key, :user, :record

    def initialize(attributes = {})
      assign_attributes(attributes)
    end

    # If a custom permission is set for a given user, use that
    # else return the user's role permission.
    #
    # NewBuild initially will only support role based permissions. At a later time,
    # when user based permissions need to be included, this shall be extracted to a
    # gem.
    def call
      user_permission.presence || role_permission
    end

    private

    def role_permission
      role = user.role
      actions(role) && actions(role)[key]
    end

    def user_permission
      @user_permission ||= actions(current_role) && actions(current_role)[key]
    end

    def actions(accessor)
      klass = record.is_a?(Class) ? record : record.class
      accessor.policies.find_by(resource: klass.name.underscore).try(:actions)
    end

    def current_role
      @current_role ||= user.user_role
    end
  end
end
