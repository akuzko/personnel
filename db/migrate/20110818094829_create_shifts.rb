class CreateShifts < ActiveRecord::Migration
  def self.up
    create_table :shifts do |t|
      t.integer :user_id
      t.date :shiftdate
      t.integer :number
      t.integer :start_event
      t.integer :end_event
      t.timestamps
    end
    add_index "shifts" , ["user_id"], :unique => false
  end

  def self.down
    drop_table :shifts
  end
end
