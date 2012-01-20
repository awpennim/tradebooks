class RemoveIndex < ActiveRecord::Migration
  def self.up
    remove_index :textbooks, :isbn
    add_index :textbooks, [:isbn, :suffix], :unique => true
  end

  def self.down
  end
end
