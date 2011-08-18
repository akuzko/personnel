class AddUserSignIn < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.column :sign_in_count, :integer, :default => 0
      t.column :current_sign_in_at, :datetime
      t.column :last_sign_in_at, :datetime
      t.column :current_sign_in_ip, :string
      t.column :last_sign_in_ip, :string
      t.column :remember_created_at, :datetime
    end
  end

  def self.down
    change_table :users do |t|
      t.remove(:sign_in_count, :current_sign_in_at, :last_sign_in_at)
      t.remove(:current_sign_in_ip, :last_sign_in_ip, :remember_created_at)
    end
  end
end
