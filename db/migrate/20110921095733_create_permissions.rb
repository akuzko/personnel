class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :title

      t.timestamps
    end
  end
end
