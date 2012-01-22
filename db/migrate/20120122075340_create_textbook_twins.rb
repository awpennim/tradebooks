class CreateTextbookTwins < ActiveRecord::Migration
  def self.up
    create_table :textbook_twins do |t|
      t.integer :isbn
      t.boolean :suffix, :default => nil
      t.integer :textbook_id

      t.timestamps
    end

    add_index :textbook_twins, [:isbn, :suffix], :unique => true
  end

  def self.down
    drop_table :textbook_twins
  end
end
