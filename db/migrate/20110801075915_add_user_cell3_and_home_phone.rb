class AddUserCell3AndHomePhone < ActiveRecord::Migration
  def self.up
    change_table :contacts do |t|
      t.column :cell3, :string
      t.column :home_phone, :string, :null => false
    end
  end

  def self.down
    change_table :contacts do |t|
      t.remove(:cell3, :home_phone)
    end
  end
end
