class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.integer :buyer_id
      t.integer :seller_id
      t.integer :seller_status, :default => 0
      t.integer :buyer_status, :default => 0

      t.timestamps
    end

    add_index :deals, :buyer_id
    add_index :deals, :seller_id
  end

  def self.down
    drop_table :deals
  end
end
