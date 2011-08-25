class CreateLateComings < ActiveRecord::Migration
  def self.up
    create_table :late_comings do |t|
      t.integer :user_id
      t.integer :shift_id
      t.integer :late_minutes
      t.string  :description
      t.timestamps
    end
    add_index "late_comings" , ["user_id"], :unique => false
    add_index "late_comings" , ["shift_id"], :unique => false
  end

  def self.down
    drop_table :late_comings
  end
end
