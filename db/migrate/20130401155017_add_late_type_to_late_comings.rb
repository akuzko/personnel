class AddLateTypeToLateComings < ActiveRecord::Migration
  def change
    change_table :late_comings do |t|
      t.column :late_type, :integer, default: 7, null: false, after: :late_minutes
    end
  end
end
