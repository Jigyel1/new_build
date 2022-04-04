# frozen_string_literal: true

class AddNewFileUploadBooleanProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :projects, :file_upload, :boolean
    end
  end
end
