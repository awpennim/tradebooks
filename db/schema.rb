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

ActiveRecord::Schema.define(:version => 20120119031813) do

  create_table "deals", :force => true do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "seller_status",                               :default => 0
    t.integer  "buyer_status",                                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",         :precision => 8, :scale => 2
    t.integer  "textbook_id"
    t.string   "description"
  end

  add_index "deals", ["buyer_id"], :name => "index_deals_on_buyer_id"
  add_index "deals", ["seller_id"], :name => "index_deals_on_seller_id"

  create_table "faqs", :force => true do |t|
    t.string   "question"
    t.text     "answer",     :default => ""
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listings", :force => true do |t|
    t.boolean  "selling",                                   :default => false
    t.decimal  "price",       :precision => 8, :scale => 2
    t.integer  "user_id"
    t.integer  "textbook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",                               :default => ""
  end

  add_index "listings", ["textbook_id", "selling"], :name => "index_listings_on_textbook_id_and_selling"
  add_index "listings", ["user_id", "textbook_id"], :name => "index_listings_on_user_id_and_textbook_id", :unique => true

  create_table "messages", :force => true do |t|
    t.text     "text",        :limit => 255
    t.integer  "sender_id"
    t.integer  "reciever_id"
    t.boolean  "read",                       :default => false
    t.string   "subject",                    :default => "(no subject)"
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

  create_table "offers", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "reciever_id"
    t.string   "message"
    t.decimal  "price"
    t.integer  "textbook_id"
    t.integer  "status",      :default => 0
    t.boolean  "selling"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offers", ["reciever_id", "textbook_id"], :name => "index_offers_on_reciever_id_and_textbook_id"
  add_index "offers", ["reciever_id"], :name => "index_offers_on_reciever_id"
  add_index "offers", ["sender_id", "reciever_id"], :name => "index_offers_on_sender_id_and_reciever_id"
  add_index "offers", ["sender_id", "textbook_id"], :name => "index_offers_on_sender_id_and_textbook_id"
  add_index "offers", ["sender_id"], :name => "index_offers_on_sender_id"

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
    t.boolean  "admin",                 :default => false
    t.string   "encrypted_password"
    t.boolean  "verified",              :default => false
    t.string   "verify_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "forgot_password_token"
    t.integer  "location",              :default => 0
    t.string   "username"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
