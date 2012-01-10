class CreateListings < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.boolean :selling
      t.decimal :price, :precision => 2
      t.integer :user_id
      t.integer :textbook_id

      t.timestamps
    end
    add_index :listings, [:user_id, :selling]
    add_index :listings, [:textbook_id, :selling]
  end

  def self.down
    drop_table :listings
  end
end
