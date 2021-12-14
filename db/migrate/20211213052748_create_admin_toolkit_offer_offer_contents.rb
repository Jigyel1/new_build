# frozen_string_literal: true

class CreateAdminToolkitOfferOfferContents < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_offer_offer_contents, id: :uuid do |t|
      t.jsonb :title, default: {}
      t.jsonb :content, default: {}
      t.timestamps
    end
  end
end
