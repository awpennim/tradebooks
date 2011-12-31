class CreateTextbooks < ActiveRecord::Migration
  def self.up
    create_table :textbooks do |t|
      t.integer :isbn
      t.string :author
      t.string :title

      t.timestamps
    end
    add_index :textbooks, :isbn, :unique => true
  end

  def self.down
    drop_table :textbooks
  end
end
