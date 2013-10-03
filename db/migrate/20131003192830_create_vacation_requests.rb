class CreateVacationRequests < ActiveRecord::Migration
  def change
    create_table :vacation_requests do |t|
      t.references :user, null: false
      t.date :started, null: false
      t.date :ended, null: false
      t.integer :status, null: false, default: 0
      t.text :comment
      t.timestamps
    end

    add_index :vacation_requests, :user_id
  end
end
