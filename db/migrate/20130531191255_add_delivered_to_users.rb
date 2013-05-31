class AddDeliveredToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :delivered, null: false, default: false
    end

    User.includes(:department).active.each do |user|
      user.update_attributes(delivered: true) if user.department.has_identifier? and user.department.show_address?
    end
  end
end
