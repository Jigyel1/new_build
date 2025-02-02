# frozen_string_literal: true

class AddAvatarUrlToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :avatar_url, :string
  end
end
