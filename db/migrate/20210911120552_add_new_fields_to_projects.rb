# frozen_string_literal: true

class AddNewFieldsToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :projects, :competition, null: true, foreign_key: { to_table: :admin_toolkit_competitions },
                                             type: :uuid
      add_reference :projects, :incharge, null: true, foreign_key: { to_table: :telco_uam_users }, type: :uuid
    end

    add_column :projects, :analysis, :text
    add_column :projects, :customer_request, :boolean
    add_column :projects, :verdicts, :jsonb, default: {}
    add_column :projects, :draft_version, :jsonb, default: {}
    add_column :projects, :system_sorted_category, :boolean, default: true
  end
end
