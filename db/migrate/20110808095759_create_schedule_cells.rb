class CreateScheduleCells < ActiveRecord::Migration
  def self.up
    create_table :schedule_cells do |t|
      t.integer :shift_id
      t.integer :line
      t.integer :day
      t.integer :user_id
      t.integer :attributes
      t.integer :responsible
      t.boolean :changed
    end
    add_index "schedule_cells" , ["shift_id"], :unique => false
  end

  def self.down
    drop_table :schedule_cells
  end
end
