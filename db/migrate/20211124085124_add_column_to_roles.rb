# frozen_string_literal: true

class AddColumnToRoles < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :description, :string
  end
end
