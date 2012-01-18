class AddDescriptionToListings < ActiveRecord::Migration
  def self.up
    add_column :listings, :description, :string, :default => ""
  end

  def self.down
    remove_column :listings, :description
  end
end
