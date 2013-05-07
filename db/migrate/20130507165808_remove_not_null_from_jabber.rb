class RemoveNotNullFromJabber < ActiveRecord::Migration
  def change
    change_column :contacts, :jabber, :string, limit: 50, null: true
  end
end
