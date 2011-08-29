class RenameInitialsToFirstname < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :initials, :first_name
  end

  def self.down
    rename_column :profiles, :first_name, :initials
  end
end