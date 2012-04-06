class AddHasScheduleToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :has_schedule, :boolean, :default => true
  end
end
