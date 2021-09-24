# frozen_string_literal: true

class CreateProjectsInstallationDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_installation_details, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.integer :sockets
      t.string :builder

      t.timestamps
    end
  end
end
