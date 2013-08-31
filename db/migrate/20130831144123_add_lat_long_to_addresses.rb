class AddLatLongToAddresses < ActiveRecord::Migration
  def change
    change_table :addresses do |t|
      t.string :lat, limit: 20
      t.string :lng, limit: 20
    end
  end
end
