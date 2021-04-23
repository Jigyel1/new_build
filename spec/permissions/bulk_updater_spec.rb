# frozen_string_literal: true

require 'rails_helper'

describe Permissions::BulkUpdater do
  let_it_be(:role) { create(:role, :super_user) }

  context 'when permission is not defined' do
    subject(:updater) { described_class.new(role: role) }

    it 'creates a new permission' do
      updater.call

      keys = Role::PERMISSIONS.dig(:super_user, :user)
      permission = role.reload.permissions.find_by!(resource: :user)

      expect(permission.actions.size).to eq(keys.size)
      expect(keys.flat_map { |key| permission.actions.values_at(key) }.uniq).to eq([true])
    end
  end

  context 'for an existing permission' do
    subject(:updater) { described_class.new(role: role) }

    let!(:permission_a) { create(:permission, actions: { read: true, invite: false, update_status: false }, accessor: role) }

    it 'updates the permission' do
      updater.call

      keys = Role::PERMISSIONS.dig(:super_user, :user)
      permission = role.reload.permissions.find_by!(resource: :user)

      expect(permission.actions.size).to eq(keys.size)

      false_keys = %w[invite update_status]
      expect(false_keys.flat_map { |key| permission.actions.values_at(key) }.uniq).to eq([false])

      true_keys = keys - false_keys
      expect(true_keys.flat_map { |key| permission.actions.values_at(key) }.uniq).to eq([true])
    end
  end

  context 'with accessor not as a role' do
    subject(:updater) { described_class.new(role: create(:user, :kam)) }

    it 'raises an error' do
      expect { updater.call }.to raise_exception(StandardError).with_message(t('permission.role_only'))
    end
  end
end
