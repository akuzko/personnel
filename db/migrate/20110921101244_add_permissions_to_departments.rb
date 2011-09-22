class AddPermissionsToDepartments < ActiveRecord::Migration

  def self.up
    create_table :department_permissions do |t|
      t.integer :department_id
      t.integer :permission_id
      t.timestamps
    end
    add_index "department_permissions" , ["department_id", "permission_id"], :unique => true
  end

  def self.down
    drop_table :department_permissions
  end

end
