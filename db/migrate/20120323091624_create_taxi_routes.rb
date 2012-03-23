class CreateTaxiRoutes < ActiveRecord::Migration
  def change
    create_table :taxi_routes do |t|
      t.date :traced

      t.timestamps
    end
  end
end
