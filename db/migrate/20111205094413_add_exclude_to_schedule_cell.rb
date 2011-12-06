class AddExcludeToScheduleCell < ActiveRecord::Migration
  def change
    add_column :schedule_cells, :exclude, :boolean, :default => 0
  end
end
