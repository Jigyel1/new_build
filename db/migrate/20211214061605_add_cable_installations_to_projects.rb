# frozen_string_literal: true

class AddCableInstallationsToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :cable_installations, :text, array: true, default: []
  end
end
