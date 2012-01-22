class AddMessageArrayToNotifications < ActiveRecord::Migration
  def self.up
    change_column :notifications, :message, :text
  end

  def self.down
    remove_column :notifications, :message, :string
  end
end
