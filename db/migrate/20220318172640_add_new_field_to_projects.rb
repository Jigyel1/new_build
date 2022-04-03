# frozen_string_literal: true

class AddNewFieldToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :projects, bulk: true do |t|
        t.references :kam_assignee, foreign_key: { to_table: :telco_uam_users }, type: :uuid
        t.string :confirmation_status, null: true, default: 'New'
        t.string :description_on_other, null: true
      end
    end
  end
end
