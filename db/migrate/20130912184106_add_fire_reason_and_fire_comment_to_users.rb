class AddFireReasonAndFireCommentToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :fire_reason
      t.text :fire_comment
    end

    fr_old = FireReason.create(name: 'old')

    User.where('fired_at IS NOT NULL').update_all(fire_reason_id: fr_old.id)
  end
end
