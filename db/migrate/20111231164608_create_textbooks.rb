class CreateTextbooks < ActiveRecord::Migration
  def self.up
    create_table :textbooks do |t|
      t.integer :isbn, :null => false
      t.string :author, :null => false
      t.string :title, :null => false
      t.boolean :suffix
      t.text :summary, :limit => 1000
      t.string :publisher_text

      t.timestamps
    end
    add_index :textbooks, :isbn, :unique => true
  end

  def self.down
    drop_table :textbooks
  end
end
