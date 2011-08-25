class AddConfirmableToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.confirmable
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :confirmation_token
      t.remove :confirmed_at
      t.remove :confirmation_sent_at
    end
  end
end
