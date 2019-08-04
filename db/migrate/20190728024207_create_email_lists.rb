class CreateEmailLists < ActiveRecord::Migration[5.2]
  def change
    create_table :email_lists do |t|
      t.string :name, null: false
      t.string :email_column
      t.boolean :verified
      t.references :user, index: true, null: false
      t.timestamps
    end
  end
end
