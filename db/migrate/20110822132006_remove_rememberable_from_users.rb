class RemoveRememberableFromUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove :remember_created_at
    end
  end

  def self.down
    change_table :users do |t|
      t.rememberable
    end
  end
end
