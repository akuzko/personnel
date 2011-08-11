class RenameColumns < ActiveRecord::Migration
  def self.up
    change_table :schedule_shifts do |t|
      t.rename(:template_id, :schedule_template_id)
    end
    change_table :schedule_cells do |t|
      t.rename(:shift_id, :schedule_shift_id)
      t.rename(:changed, :is_modified)
      t.rename(:attributes, :additional_attributes)
    end
  end

  def self.down
    change_table :schedule_shifts do |t|
      t.rename(:schedule_template_id, :template_id)
    end
    change_table :schedule_cells do |t|
      t.rename(:schedule_shift_id, :shift_id)
      t.rename(:is_modified, :changed)
      t.rename(:additional_attributes, :attributes)
    end
  end
end
