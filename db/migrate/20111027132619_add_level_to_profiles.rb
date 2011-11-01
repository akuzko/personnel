class AddLevelToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :level, :string
  end
end
