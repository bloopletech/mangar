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

ActiveRecord::Schema.define(:version => 20150612083701) do

  create_table "collections", :force => true do |t|
    t.string   "path"
    t.string   "config"
    t.datetime "last_opened_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "title",          :limit => 500
    t.text     "path"
    t.text     "filename"
    t.text     "preview"
    t.integer  "opens",                         :default => 0
    t.integer  "page_count",                    :default => 0
    t.datetime "published_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "win",                           :default => false
    t.boolean  "fail",                          :default => false
    t.datetime "last_opened_at"
    t.string   "sort_key"
    t.string   "type"
  end

  create_table "preferences", :force => true do |t|
    t.text     "name"
    t.text     "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
