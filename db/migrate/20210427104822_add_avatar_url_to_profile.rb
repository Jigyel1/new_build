class AddAvatarUrlToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :avatar_url, :string, null: false, default: ''
  end
end
