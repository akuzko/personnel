class AddSuperUserFieldToAdmin < ActiveRecord::Migration
  def self.up
    add_column :admins, :super_user, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :admins, :super_user
  end
end
