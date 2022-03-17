# frozen_string_literal: true

class AddNewFieldToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :confirmation_status, :string, default: 'New'
  end
end
