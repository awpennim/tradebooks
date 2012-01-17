class ChangeMessageTextType < ActiveRecord::Migration
  def self.up
    change_column :messages, :text, :text 
  end

  def self.down
  end
end
