class AddHasEventsToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :has_events, :boolean, :default => 1
  end
end
