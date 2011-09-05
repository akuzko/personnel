class AddEventIp < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.integer :ip_address
    end
  end
end
