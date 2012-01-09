class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :message
      t.boolean :read, :default => false
      t.integer :user_id

      t.timestamps
    end

    add_index :notifications, :user_id
  end

  def self.down
    drop_table :notifications
  end
end
