class AddDisplayOrderToCategory < ActiveRecord::Migration
  def change
    change_table :categories do |t|
      t.integer :display_order, :default => 0, :null => false
    end
  end
end
