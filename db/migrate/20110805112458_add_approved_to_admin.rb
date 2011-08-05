class AddApprovedToAdmin < ActiveRecord::Migration
  def self.up
    add_column :admins, :approved, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :admins, :approved
  end
end
