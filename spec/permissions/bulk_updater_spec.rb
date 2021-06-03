# frozen_string_literal: true

require 'rails_helper'

describe Permissions::BulkUpdater do
  let_it_be(:role) { create(:role, :super_user) }

  context 'with accessor as role' do
    subject(:updater) { described_class.new(role: role) }

    describe '.seed_default!' do
      before { allow(updater).to receive(:update_permission!).and_return(double) } # rubocop:disable RSpec/SubjectStub

      it 'creates permission with all action values as false' do
        updater.call

        keys = Rails.application.config.role_permissions.dig(:super_user, :user)
        permission = role.reload.permissions.find_by!(resource: :user)

        expect(permission.actions.size).to eq(keys.size)
        expect(keys.flat_map { |key| permission.actions.values_at(key) }.uniq).to eq([false])
      end
    end

    describe '.update!' do
      it 'updates the permission with actions relevant to the given role' do
        updater.call

        keys = Rails.application.config.role_permissions.dig(:super_user, :user)
        permission = role.reload.permissions.find_by!(resource: :user)
        expect(permission.actions.size).to eq(keys.size)
        expect(keys.flat_map { |key| permission.actions.values_at(key) }.uniq).to eq([true])
      end
    end
  end

  context 'with accessor not as a role' do
    subject(:updater) { described_class.new(role: create(:user, :kam)) }

    it 'raises an error' do
      expect { updater.call }.to raise_exception(StandardError).with_message(t('permission.role_only'))
    end
  end
end
