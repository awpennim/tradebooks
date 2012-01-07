class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :salt
      t.boolean :admin, :default => false
      t.string :encrypted_password
      t.boolean :verified, :default => false
      t.string :verify_token

      t.timestamps
    end

    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table :users
  end
end
