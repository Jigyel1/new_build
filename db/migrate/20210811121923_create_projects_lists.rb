class CreateProjectsLists < ActiveRecord::Migration[6.1]
  def change
    create_view :projects_lists
  end
end
