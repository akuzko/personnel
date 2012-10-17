class CreateShiftLeaderScores < ActiveRecord::Migration
  def change
    create_table :shift_leader_scores do |t|
      t.date :shift_date
      t.integer :shift_number
      t.integer :shift_leader_id
      t.references :user
      t.integer :score
      t.string :comment
      t.timestamps
    end
  end
end
