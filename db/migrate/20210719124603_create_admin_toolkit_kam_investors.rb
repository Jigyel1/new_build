# frozen_string_literal: true

class CreateAdminToolkitKamInvestors < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_kam_investors, id: :uuid do |t|
      t.references :kam, null: false, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.string :investor_id, null: false, index: { unique: :case_insensitive_comparison }
      t.text :investor_description

      t.timestamps
    end
  end
end
