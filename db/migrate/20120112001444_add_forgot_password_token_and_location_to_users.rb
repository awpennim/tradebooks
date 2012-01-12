class AddForgotPasswordTokenAndLocationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :forgot_password_token, :string
    add_column :users, :location, :integer, :default => 0
  end

  def self.down
    remove_column :users, :location
    remove_column :users, :forgot_password_token
  end
end
