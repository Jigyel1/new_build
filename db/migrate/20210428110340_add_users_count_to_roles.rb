class AddUsersCountToRoles < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :users_count, :integer, default: 0, null: false

    # If the counter cache column is added after records(users/roles) are already available.
    Role.find_each do |role|
      Role.reset_counters(role.id, :users)
    end
  end
end
