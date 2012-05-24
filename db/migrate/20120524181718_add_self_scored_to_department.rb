class AddSelfScoredToDepartment < ActiveRecord::Migration
  def change
    add_column :departments, :self_scored, :boolean, :default => false
  end
end
