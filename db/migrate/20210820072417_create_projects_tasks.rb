# frozen_string_literal: true

class CreateProjectsTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_tasks, id: :uuid do |t|
      t.references :taskable, type: :uuid, polymorphic: true, null: false
      t.string :title, null: false
      t.string :status, null: false, default: 'To-Do'
      t.string :previous_status
      t.text :description, null: false
      t.date :due_date, null: false
      t.references :assignee, null: false, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.references :owner, null: false, foreign_key: { to_table: :telco_uam_users }, type: :uuid

      t.timestamps
    end

    add_index :projects_tasks, :updated_at, order: :desc
  end
end
