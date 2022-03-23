class AddAddedLabelsToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :added_labels, :string
  end
end
