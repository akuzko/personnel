class AddUniqueIndexToScheduleShifts < ActiveRecord::Migration
  def up
    change_table :schedule_shifts do |t|
      t.index([:schedule_template_id, :number], :unique => true)
    end
  end

  def down
    change_table :schedule_shifts do |t|
      t.remove_index :column => [:schedule_template_id, :number]
    end
  end
end
