class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.string :address, index: true, null: false
      t.boolean :mx_record_validity
      t.boolean :domain_validity
      t.boolean :format_validity
      t.boolean :is_valid
      t.references :email_list, index: true, null: false
      t.timestamps
    end
  end
end
