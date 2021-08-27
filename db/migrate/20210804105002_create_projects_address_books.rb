# frozen_string_literal: true

class CreateProjectsAddressBooks < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics::SeliseMethodLength
    create_table :projects_address_books, id: :uuid do |t|
      t.string :external_id, index: true
      t.string :type, null: false
      t.string :display_name, null: false
      t.string :entry_type, null: false

      t.boolean :main_contact, null: false, default: false
      t.string :name, null: false
      t.string :additional_name
      t.string :company
      t.string :po_box
      t.string :language
      t.string :phone
      t.string :mobile
      t.string :email
      t.string :website
      t.string :province
      t.string :contact
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
