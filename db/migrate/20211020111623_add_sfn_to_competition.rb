# frozen_string_literal: true

class AddSfnToCompetition < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :admin_toolkit_competitions, :sfn, :boolean, default: false
    add_index :admin_toolkit_competitions, :sfn, algorithm: :concurrently
  end
end
