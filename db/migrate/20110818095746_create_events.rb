class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :user_id
      t.integer :category_id
      t.datetime :eventtime
      t.string :description
      t.timestamps
    end
    add_index "events" , ["user_id"], :unique => false
    add_index "events" , ["category_id"], :unique => false
  end

  def self.down
    drop_table :events
  end
end
