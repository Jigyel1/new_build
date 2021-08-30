class CreateProjectsLabelGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_label_groups, id: :uuid do |t|
      t.string :name, null: false
      t.string :label_list, null: false, index: true, default: [], array: true
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.references :label_group, null: false, foreign_key: { to_table: :admin_toolkit_label_groups }, type: :uuid

      t.timestamps
    end
  end
end
