# frozen_string_literal: true

class AddOwnerToActiveStorageAttachments < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :active_storage_attachments, :owner, foreign_key: { to_table: :telco_uam_users },
                                                         type: :uuid
    end
  end
end
