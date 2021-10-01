# frozen_string_literal: true

class AddNewFieldsToProjects < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/SeliseMethodLength
    safety_assured do
      add_reference(
        :projects,
        :competition,
        foreign_key: { to_table: :admin_toolkit_competitions },
        type: :uuid
      )

      add_reference(
        :projects,
        :incharge,
        foreign_key: { to_table: :telco_uam_users },
        type: :uuid
      )

      change_table :projects, bulk: true do |t|
        t.text :analysis
        t.boolean :customer_request
        t.jsonb :verdicts, default: {}
        t.jsonb :draft_version, default: {}
        t.boolean :system_sorted_category, default: true
      end
    end
  end
end
