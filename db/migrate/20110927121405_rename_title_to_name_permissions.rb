class RenameTitleToNamePermissions < ActiveRecord::Migration
  def up
    rename_column :permissions, :title, :name
  end

  def down
    rename_column :permissions, :name, :title
  end
end
