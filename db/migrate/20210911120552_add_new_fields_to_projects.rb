class AddNewFieldsToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :projects, :competition, null: true, foreign_key: { to_table: :admin_toolkit_competitions }, type: :uuid
    end

    add_column :projects, :analysis, :text
    add_column :projects, :customer_request, :boolean
    add_column :projects, :verdicts, :jsonb, default: {}, null: false
  end
end
