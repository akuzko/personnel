class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string  :name
      t.integer :department_id
      t.boolean :displayed
      t.boolean :reported
      t.timestamps
    end
    add_index "categories" , ["department_id"], :unique => false
  end

  def self.down
    drop_table :categories
  end
end
