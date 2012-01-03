class AddComboKeyOnShiftLineDayToCells < ActiveRecord::Migration
  def up
    add_index(:schedule_cells, [:schedule_shift_id, :line, :day], :unique => true, :name => 'by_shift_line_day')
  end

  def down
    remove_index :schedule_cells, :name => :by_shift_line_day
  end
end
