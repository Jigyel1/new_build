class RemoveReferenceToCompetitionFromPenetration < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :admin_toolkit_penetrations, :competition_id, :integer }
  end
end
