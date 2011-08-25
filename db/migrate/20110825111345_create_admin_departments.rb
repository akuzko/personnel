class CreateAdminDepartments < ActiveRecord::Migration
  def self.up
    create_table :admin_departments do |t|
      t.integer :admin_id
      t.integer :department_id
      t.timestamps
    end
    add_index "admin_departments" , ["admin_id", "department_id"], :unique => true
  end

  def self.down
    drop_table :admin_departments
  end
end
