class CreateScheduleTemplates < ActiveRecord::Migration
  def self.up
    create_table :schedule_templates do |t|
      t.integer :department_id
      t.integer :year
      t.integer :month
      t.boolean :visible, :default => false, :null => false
    end
    add_index "schedule_templates" , ["department_id", "year", "month"], :unique => true
  end

  def self.down
    drop_table :schedule_templates
  end
end
