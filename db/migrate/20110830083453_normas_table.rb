class NormasTable < ActiveRecord::Migration
  def self.up
    create_table :norms do |t|
      t.column :user_id,  :integer
      t.column :year,     :integer
      t.column :month,    :integer
      t.column :workdays, :integer
      t.column :weekend,  :integer
    end
  end

  def self.down
    drop_table :norms
  end
end