# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :street, default: ''
      t.string :street_no, default: ''
      t.string :city, default: ''
      t.string :zip, default: ''

      t.references :addressable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
