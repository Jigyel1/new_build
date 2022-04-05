# frozen_string_literal: true

# This migration comes from telco_uam (originally 20210316115307)

class DeviseInvitableAddToTelcoUamUsers < ActiveRecord::Migration[6.1]
  def up # rubocop:disable Metrics/SeliseMethodLength,
    safety_assured do
      change_table :telco_uam_users, bulk: true do |t|
        t.string :invitation_token
        t.datetime :invitation_created_at
        t.datetime :invitation_sent_at
        t.datetime :invitation_accepted_at
        t.integer :invitation_limit
        t.references :invited_by, polymorphic: true, type: :uuid
        t.integer :invitations_count, default: 0
        t.index :invitation_token, unique: true # for invitable
        t.index :invited_by_id
      end
    end
  end

  def down
    change_table :telco_uam_users do |t| # rubocop:disable Rails/BulkChangeTable
      t.remove_references :invited_by, polymorphic: true
      t.remove :invitations_count, :invitation_limit, :invitation_sent_at, :invitation_accepted_at, :invitation_token,
               :invitation_created_at
    end
  end
end
