class CreateListings < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.boolean :selling, :default => false
      t.decimal :price, :precision => 8, :scale => 2
      t.integer :user_id
      t.integer :textbook_id

      t.timestamps
    end
    add_index :listings, [:user_id, :textbook_id], :unique => true
    add_index :listings, [:textbook_id, :selling]
  end

  def self.down
    drop_table :listings
  end
end
