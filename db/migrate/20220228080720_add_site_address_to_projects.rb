# frozen_string_literal: true

class AddSiteAddressToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :site_address, :jsonb
  end
end
