class AddShowAddressToDepartment < ActiveRecord::Migration
  def change
    add_column :departments, :show_address, :boolean, :default => 1
  end
end
