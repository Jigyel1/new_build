# frozen_string_literal: true

class AddPrioStatusToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :projects, :prio_status, :string
    end
  end
end
