class AddPermissionsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.text :extended_permissions
    end
  end
end
