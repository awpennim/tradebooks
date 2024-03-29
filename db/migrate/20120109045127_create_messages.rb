class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :reciever_id
      t.boolean :read, :default => false
      t.string :subject, :default => "(no subject)"
      t.text :text

      t.timestamps
    end

    add_index :messages, :sender_id
    add_index :messages, :reciever_id
  end

  def self.down
  end
end
