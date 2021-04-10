# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: { to_table: :telco_uam_users }
      t.string :salutation, null: false
      t.string :firstname, default: '', null: false
      t.string :lastname, default: '', null: false
      t.string :phone, null: false
      t.string :department

      t.timestamps
    end

    add_index :profiles, %i[firstname lastname]
  end
end
