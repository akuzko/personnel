class ChangeVisibleFieldInScheduleTemplates < ActiveRecord::Migration
  def change
    change_table :schedule_templates do |t|
      t.change(:visible, :integer)
    end
  end
end
