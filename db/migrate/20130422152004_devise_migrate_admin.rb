class DeviseMigrateAdmin < ActiveRecord::Migration
  def up
    change_table :admins do |t|
      t.datetime :reset_password_sent_at
    end
  end

  def down
    change_table :admins do |t|
      t.remove(:reset_password_sent_at)
    end
  end
end
