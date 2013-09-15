class CreateFireReasons < ActiveRecord::Migration
  def change
    create_table :fire_reasons do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
