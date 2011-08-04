class RemoveNotNullFromPhoneColumn < ActiveRecord::Migration
  def self.up
    change_table :contacts do |t|
      t.change(:home_phone, :string, :null => true)
    end
  end

  def self.down
    change_table :contacts do |t|
      t.change(:home_phone, :string, :null => false)
    end
  end
end
