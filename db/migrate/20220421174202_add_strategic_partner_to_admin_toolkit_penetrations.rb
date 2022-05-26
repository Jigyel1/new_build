# frozen_string_literal: true

class AddStrategicPartnerToAdminToolkitPenetrations < ActiveRecord::Migration[6.1]
  def change
    safety_assured { add_column :admin_toolkit_penetrations, :strategic_partner, :string }
  end
end
