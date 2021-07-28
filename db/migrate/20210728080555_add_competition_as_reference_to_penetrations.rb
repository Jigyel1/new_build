class AddCompetitionAsReferenceToPenetrations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured { remove_column :admin_toolkit_penetrations, :competition, :string }
    add_reference :admin_toolkit_penetrations, :competition, type: :uuid, index: {algorithm: :concurrently}
  end
end