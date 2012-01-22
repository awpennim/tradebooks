class Fakeadsf < ActiveRecord::Migration
  def self.up
    change_column :notifications, :messages, :string
  end

  def self.down
    change_column :notifications, :messages, :text
  end
end
