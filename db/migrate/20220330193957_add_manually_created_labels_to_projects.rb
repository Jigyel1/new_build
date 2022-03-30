class AddManuallyCreatedLabelsToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :manually_created_labels, :text, array: true, default: []
  end
end
