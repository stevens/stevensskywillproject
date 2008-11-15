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

ActiveRecord::Schema.define(:version => 26) do

  create_table "codes", :force => true do |t|
    t.string   "codeable_type"
    t.string   "code"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "codes", ["codeable_type"], :name => "pi_codeable_type"

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contactor_id"
    t.string   "contact_type"
    t.string   "status"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counters", :force => true do |t|
    t.string   "countable_type"
    t.integer  "countable_id"
    t.integer  "total_view_count"
    t.integer  "user_view_count"
    t.integer  "self_view_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "counters", ["countable_type", "countable_id"], :name => "pi_countable"
  add_index "counters", ["countable_type"], :name => "pi_countable_type"

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.string   "favorable_type"
    t.integer  "favorable_id"
    t.string   "status"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["user_id"], :name => "fk_user"
  add_index "favorites", ["favorable_type"], :name => "pi_favorable_type"
  add_index "favorites", ["user_id", "favorable_type"], :name => "i_user_favorable_type"
  add_index "favorites", ["favorable_type", "favorable_id"], :name => "pi_favorable"
  add_index "favorites", ["user_id", "favorable_type", "favorable_id"], :name => "i_user_favorable"
  add_index "favorites", ["favorable_type", "status"], :name => "i_favorable_type_status"
  add_index "favorites", ["user_id", "favorable_type", "status"], :name => "i_user_favorable_type_status"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.string   "category"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "submitter_type"
    t.string   "submitter_name"
    t.string   "submitter_email"
  end

  add_index "feedbacks", ["user_id"], :name => "fk_user"
  add_index "feedbacks", ["category"], :name => "i_category"
  add_index "feedbacks", ["user_id", "category"], :name => "i_user_category"

  create_table "homepages", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "user_id"
    t.text     "caption"
    t.string   "photoable_type"
    t.integer  "photoable_id"
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
    t.string   "photo_type"
  end

  add_index "photos", ["user_id"], :name => "fk_user"
  add_index "photos", ["photoable_type"], :name => "pi_photoable_type"
  add_index "photos", ["user_id", "photoable_type"], :name => "i_user_photoable_type"
  add_index "photos", ["user_id", "photoable_type", "photoable_id"], :name => "i_user_photoable"
  add_index "photos", ["parent_id"], :name => "i_parent_photo"
  add_index "photos", ["photoable_type", "photoable_id"], :name => "pi_photoable"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "gender"
    t.string   "gender_show_type"
    t.datetime "birthday"
    t.string   "birthday_show_type"
    t.string   "location"
    t.string   "hometown"
    t.string   "blog"
    t.text     "intro"
    t.string   "privacy"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rating"
    t.string   "rateable_type"
    t.integer  "rateable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rateable_type", "rateable_id"], :name => "pi_rateable"
  add_index "ratings", ["rateable_type"], :name => "pi_rateable_type"
  add_index "ratings", ["user_id"], :name => "fk_user"
  add_index "ratings", ["user_id", "rateable_type"], :name => "i_user_rateable_type"

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
    t.string   "prep_time"
    t.string   "cook_time"
    t.string   "yield"
    t.string   "from_type"
    t.text     "from_where"
    t.string   "cost"
    t.text     "video_url"
    t.string   "status"
    t.string   "privacy"
    t.text     "any_else"
    t.datetime "published_at"
    t.string   "is_draft"
  end

  add_index "recipes", ["user_id"], :name => "fk_user"

  create_table "reviews", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "review"
    t.string   "reviewable_type"
    t.integer  "reviewable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["reviewable_type", "reviewable_id"], :name => "pi_reviewable"
  add_index "reviews", ["reviewable_type"], :name => "pi_reviewable_type"
  add_index "reviews", ["user_id"], :name => "fk_user"
  add_index "reviews", ["user_id", "reviewable_type"], :name => "i_user_reviewable_type"
  add_index "reviews", ["user_id", "reviewable_type", "reviewable_id"], :name => "i_user_reviewable"

  create_table "stories", :force => true do |t|
    t.integer  "user_id"
    t.string   "storyable_type"
    t.integer  "storyable_id"
    t.string   "story_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["taggable_type", "taggable_id"], :name => "pi_taggable"
  add_index "taggings", ["taggable_type"], :name => "pi_taggable_type"
  add_index "taggings", ["tag_id"], :name => "fk_tag"
  add_index "taggings", ["tag_id", "taggable_type"], :name => "i_tag_taggable_type"

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
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                 :default => true
    t.datetime "latest_loggedin_at"
    t.integer  "login_count"
  end

end
