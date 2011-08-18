class CreateScheduleStatuses < ActiveRecord::Migration
  def self.up
    create_table :schedule_statuses do |t|
      t.string :name, :unique => true, :null => false
      t.string :color, :null => false
    end
    add_index "schedule_statuses" , "name", :unique => true
  end

  def self.down
    drop_table :schedule_statuses
  end
end
