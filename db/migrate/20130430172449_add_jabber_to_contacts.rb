class AddJabberToContacts < ActiveRecord::Migration
  def change
    change_table :contacts do |t|
      t.string :jabber, limit: 50, null: false
    end
  end
end
