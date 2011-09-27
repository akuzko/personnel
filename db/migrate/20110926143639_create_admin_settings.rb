class CreateAdminSettings < ActiveRecord::Migration
  def up
    create_table :admin_settings do |t|
      t.integer :admin_id
      t.string :key
      t.string :value
      t.timestamps
    end
    add_index "admin_settings" , ["admin_id", "key", "value"], :unique => true
  end

  def down
    drop_table :admin_settings
  end
end
