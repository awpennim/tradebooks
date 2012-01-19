class AddPriceToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :deals, :price
  end
end
