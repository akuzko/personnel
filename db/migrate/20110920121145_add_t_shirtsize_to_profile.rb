class AddTShirtsizeToProfile < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.string :t_short_size
    end
  end
end
