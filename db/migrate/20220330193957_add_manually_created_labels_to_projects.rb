class AddManuallyCreatedLabelsToProjects < ActiveRecord::Migration[6.1]
  def change
    def change
      safety_assured do
        change_table :projects, bulk: true do |t|
          t.text :manually_created_labels, array: true, default: []
        end
      end
    end
  end
end
