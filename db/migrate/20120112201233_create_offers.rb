class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.integer :sender_id
      t.integer :reciever_id
      t.string :message
      t.decimal :price
      t.integer :textbook_id
      t.integer :status, :default => 0
      t.boolean :selling

      t.timestamps
    end

    add_index :offers, :sender_id
    add_index :offers, :reciever_id
    add_index :offers, [:sender_id,:textbook_id]
    add_index :offers, [:reciever_id,:textbook_id]
    add_index :offers, [:sender_id, :reciever_id]
  end

  def self.down
    drop_table :offers
  end
end
