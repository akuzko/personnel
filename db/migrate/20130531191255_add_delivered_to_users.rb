class AddDeliveredToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :deliverable, null: false, default: false
    end

    User.includes(:department).active.each do |user|
      user.update_attributes(deliverable: true) if user.department.has_identifier? and user.department.show_address?
    end
  end
end
