class AddActiveFieldtoUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.column :active, :boolean, :default => false, :null => false
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :active
    end
  end
end
