class AddCanEditScheduleToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :can_edit_schedule, :default => 0 , :null => false
    end
  end
end
