class AddTshortedToDepartments < ActiveRecord::Migration
  def change
    change_table :departments do |t|
      t.boolean :has_t_short, :default => 0
    end
  end
end
