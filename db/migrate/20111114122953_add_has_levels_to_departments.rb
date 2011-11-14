class AddHasLevelsToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :has_levels, :boolean, :default => 0
  end
end
