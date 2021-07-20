# frozen_string_literal: true

class CreateAdminToolkitCompetitions < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_competitions, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.float :factor, null: false
      t.decimal :lease_rate, null: false
      t.text :description

      t.timestamps
    end
  end
end
