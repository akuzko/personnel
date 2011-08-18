class AddPrimaryAddressColumn < ActiveRecord::Migration
  def self.up
    add_column :addresses, :primary, :boolean, :default => 0
  end

  def self.down
    remove_column :addresses, :primary
  end
end
