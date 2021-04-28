class EnableHstore < ActiveRecord::Migration[6.1]
  def change
    enable_extension :hstore
  end
end
