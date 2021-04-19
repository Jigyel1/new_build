class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_view :users
  end
end
