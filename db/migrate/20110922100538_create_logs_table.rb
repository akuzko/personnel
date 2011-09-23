class CreateLogsTable < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.text :body
      t.references :subject, :polymorphic => true
      t.references :author, :polymorphic => true
      t.timestamps
    end
    add_index "logs" , ["subject_id", "subject_type"], :unique => false
    add_index "logs" , ["author_id", "author_type"], :unique => false
  end

  def self.down
    drop_table :logs
  end
end
