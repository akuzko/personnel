class UpgradeDevise < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
    end
  end

  def down
    change_table :users do |t|
      t.remove(:reset_password_sent_at, :remember_created_at)
    end
  end
end
