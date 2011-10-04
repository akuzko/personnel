class RenameTShortToTShirtInProfiles < ActiveRecord::Migration
  def up
    rename_column :profiles, :t_short_size, :t_shirt_size
    rename_column :departments, :has_t_short, :has_t_shirt
  end

  def down
    rename_column :profiles, :t_shirt_size, :t_short_size
    rename_column :departments, :has_t_shirt, :has_t_short
  end
end
