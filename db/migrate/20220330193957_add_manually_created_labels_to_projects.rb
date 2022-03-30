class AddManuallyCreatedLabelsToProjects < ActiveRecord::Migration[6.1]
  def change
    def up
      add_column :projects, :manually_created_labels, :string, default: [], array: true
      change_column_default :projects, :manually_created_labels, []
    end

    def down
      remove_column :projects, :manually_created_labels
    end
  end
end
