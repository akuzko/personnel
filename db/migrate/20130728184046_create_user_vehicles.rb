class CreateUserVehicles < ActiveRecord::Migration
  def change
    create_table(:user_vehicles, options: 'DEFAULT CHARSET=utf8') do |t|
      t.references :user
      t.integer :vehicle_type, null: false
      t.string :brand, null: false
      t.string :reg_number, null: false
      t.timestamps
    end

    add_index :user_vehicles, :user_id
  end
end
