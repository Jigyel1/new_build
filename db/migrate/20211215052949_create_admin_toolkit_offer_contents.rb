# frozen_string_literal: true

class CreateAdminToolkitOfferContents < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_offer_contents, id: :uuid do |t|
      t.jsonb :title, default: {}
      t.jsonb :content, default: {}
      t.timestamps
    end
  end
end
