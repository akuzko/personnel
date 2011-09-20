class AddHiredAndFiredToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.date :hired_at
      t.date :fired_at
      t.boolean :fired, :default => 0
    end
  end

  def down
    change_table :users do |t|
      t.remove :hired_at
      t.remove :fired_at
      t.remove :fired
    end
  end
end
