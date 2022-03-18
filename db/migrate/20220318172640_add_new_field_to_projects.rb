class AddNewFieldToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :confirmation_status, :string
  end
end
