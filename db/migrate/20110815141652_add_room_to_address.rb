class AddRoomToAddress < ActiveRecord::Migration
  def self.up
    change_table :addresses do |t|
      t.column :room, :string, :null => false
    end
  end

  def self.down
    change_table :addresses do |t|
      t.remove(:room)
    end
  end
end
