# frozen_string_literal: true

class AddCodeToCompetitions < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_toolkit_competitions, :code, :string
  end
end
