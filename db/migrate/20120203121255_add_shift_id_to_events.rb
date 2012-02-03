class AddShiftIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :shift_id, :integer, :after => 'id'
  end
end
