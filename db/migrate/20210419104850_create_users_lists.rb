class CreateUsersLists < ActiveRecord::Migration[6.1]
  def change
    create_view :users_lists
  end
end
