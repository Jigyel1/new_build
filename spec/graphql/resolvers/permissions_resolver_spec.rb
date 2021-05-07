# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::PermissionsResolver do
  describe '.resolve' do
    it 'returns acceptable permissions for each role' do
      response, errors = formatted_response(query)
      expect(errors).to be_nil

      super_user_permissions = response.permissions.super_user
      expect(super_user_permissions.user).to match_array(Role::PERMISSIONS.dig(:super_user, :user))

      admin_permissions = response.permissions.administrator
      expect(admin_permissions.user).to match_array(Role::PERMISSIONS.dig(:administrator, :user))
    end
  end

  def query
    <<~GQL
      query { permissions }
    GQL
  end
end
