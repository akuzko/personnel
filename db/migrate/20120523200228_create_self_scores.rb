class CreateSelfScores < ActiveRecord::Migration
  def change
    create_table :self_scores do |t|
      t.date :score_date
      t.references :user
      t.integer :score
      t.string :comment
      t.timestamps
    end
  end
end
