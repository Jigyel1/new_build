# frozen_string_literal: true

class AddStrategicPartnerToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured { add_column :projects, :strategic_partner, :string }
  end
end
