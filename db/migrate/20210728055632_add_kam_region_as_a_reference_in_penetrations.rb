class AddKamRegionAsAReferenceInPenetrations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured { remove_column :admin_toolkit_penetrations, :kam_region, :string }
    add_reference :admin_toolkit_penetrations, :kam_region, type: :uuid, index: {algorithm: :concurrently}
  end
end
