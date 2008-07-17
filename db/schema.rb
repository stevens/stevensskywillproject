# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 14) do

  create_table "codes", :force => true do |t|
    t.integer  "data_element_id"
    t.string   "code"
    t.string   "name"
    t.string   "language"
    t.text     "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_elements", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "category"
    t.string   "language"
    t.text     "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "infos", :force => true do |t|
    t.string   "code"
    t.string   "text"
    t.string   "category"
    t.string   "language"
    t.text     "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "user_id"
    t.text     "caption"
    t.string   "photo_type"
    t.integer  "belong_to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type", :limit => 100
    t.string   "filename"
    t.string   "path"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
  end

  add_index "photos", ["user_id"], :name => "fk_photos_user"

  create_table "photos_b", :force => true do |t|
    t.integer  "user_id"
    t.integer  "belong_to_id"
    t.text     "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type",   :limit => 100
    t.string   "filename"
    t.string   "path"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "belong_to_type"
  end

  create_table "photos_backup", :force => true do |t|
    t.integer  "user_id"
    t.text     "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type", :limit => 100
    t.string   "filename"
    t.string   "path"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "recipes", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.text     "ingredients"
    t.text     "directions"
    t.text     "tips"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cover_photo_id"
    t.string   "difficulty"
    t.integer  "prep_time"
    t.integer  "cook_time"
    t.string   "yield"
  end

  add_index "recipes", ["user_id"], :name => "fk_recipes_user"

  create_table "reviews", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "review"
    t.string   "reviewable_type"
    t.integer  "reviewable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["user_id"], :name => "fk_reviews_user"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
  end

end
