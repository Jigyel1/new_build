
class UpdateVerfictsFromProjects < ActiveRecord::Migration[6.1]
  def change
    def up
      safety_assured do
        change_column :projects, :verdicts, :jsonb, null: true, default: {}
        remove_column :projects, :verdicts, :jsonb, default: {}
      end
    end

    def down
      change_column :projects, :verdicts, :jsonb, default: {}
    end
  end
end
