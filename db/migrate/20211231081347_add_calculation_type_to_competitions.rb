# frozen_string_literal: true

class AddCalculationTypeToCompetitions < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_toolkit_competitions, :calculation_type, :string, default: :dsl
  end
end
