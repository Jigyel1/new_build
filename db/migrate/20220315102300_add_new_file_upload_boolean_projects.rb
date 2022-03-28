# frozen_string_literal: true

class AddNewFileUploadBooleanProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :file_upload, :boolean, default: false
  end
end
