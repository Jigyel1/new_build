class CreateProjectsAddressBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_address_books, id: :uuid do |t|
      t.string :name, null: false
      t.string :additional_name
      t.string :company, null: false
      t.string :po_box
      t.string :language
      t.string :phone, null: false
      t.string :mobile, null: false
      t.string :email, null: false
      t.string :website, null: false
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
