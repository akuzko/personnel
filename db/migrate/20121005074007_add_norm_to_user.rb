class AddNormToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :norm, :default => 8, :null => false
    end
  end
end
