# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120110045626) do

  create_table "listings", :force => true do |t|
    t.boolean  "selling",                                   :default => false
    t.decimal  "price",       :precision => 8, :scale => 2
    t.integer  "user_id"
    t.integer  "textbook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "listings", ["textbook_id", "selling"], :name => "index_listings_on_textbook_id_and_selling"
  add_index "listings", ["user_id", "textbook_id"], :name => "index_listings_on_user_id_and_textbook_id", :unique => true

  create_table "messages", :force => true do |t|
    t.string   "text"
    t.integer  "sender_id"
    t.integer  "reciever_id"
    t.boolean  "read",        :default => false
    t.string   "subject",     :default => "(no subject)"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["reciever_id"], :name => "index_messages_on_reciever_id"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"

  create_table "notifications", :force => true do |t|
    t.string   "message"
    t.boolean  "read",       :default => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "textbooks", :force => true do |t|
    t.integer  "isbn",           :null => false
    t.string   "author",         :null => false
    t.string   "title",          :null => false
    t.boolean  "suffix"
    t.text     "summary"
    t.string   "publisher_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "textbooks", ["isbn"], :name => "index_textbooks_on_isbn", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "salt"
    t.boolean  "admin",              :default => false
    t.string   "encrypted_password"
    t.boolean  "verified",           :default => false
    t.string   "verify_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
