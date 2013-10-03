class AddVacationNormToDepartments < ActiveRecord::Migration
  def change
    change_table :departments do |t|
      t.integer :vacation_norm, null: false, default: 14
    end
  end
end
