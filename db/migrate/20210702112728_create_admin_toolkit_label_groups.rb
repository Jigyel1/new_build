# frozen_string_literal: true

class CreateAdminToolkitLabelGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_label_groups, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false, index: true
      t.string :label_list, null: false, index: true, default: [], array: true
      t.timestamps
    end
  end
end
