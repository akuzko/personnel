class CreateScheduleShifts < ActiveRecord::Migration
  def self.up
    create_table :schedule_shifts do |t|
      t.integer :template_id
      t.integer :lines
      t.integer :number
      t.integer :start
      t.integer :end
    end
    add_index "schedule_shifts" , ["template_id"], :unique => false
  end

  def self.down
    drop_table :schedule_shifts
  end
end
