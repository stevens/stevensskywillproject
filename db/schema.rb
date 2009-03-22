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

ActiveRecord::Schema.define(:version => 54) do

  create_table "awards", :force => true do |t|
    t.integer  "match_id"
    t.string   "title"
    t.text     "description"
    t.integer  "level"
    t.string   "quota"
    t.string   "prize_title"
    t.text     "prize_description"
    t.string   "prize_value"
    t.integer  "cover_photo_id"
    t.string   "status"
    t.integer  "photos_count"
    t.integer  "reviews_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "awardable_type"
    t.integer  "winners_count"
    t.string   "decide_mode"
    t.string   "award_type"
  end

  add_index "awards", ["match_id"], :name => "fk_match"

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

  add_index "contacts", ["user_id"], :name => "fk_user"
  add_index "contacts", ["contactor_id"], :name => "fk_contactor"
  add_index "contacts", ["user_id", "contactor_id"], :name => "i_user_contactor"
  add_index "contacts", ["user_id", "contact_type"], :name => "i_user_contact_type"
  add_index "contacts", ["contactor_id", "contact_type"], :name => "i_contactor_contact_type"
  add_index "contacts", ["user_id", "contactor_id", "contact_type"], :name => "i_user_contactor_contact_type"

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

  create_table "courses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "menu_id"
    t.integer  "recipe_id"
    t.integer  "cover_photo_id"
    t.string   "title"
    t.string   "common_title"
    t.text     "description"
    t.text     "any_else"
    t.integer  "sequence"
    t.string   "roles"
    t.string   "status"
    t.string   "privacy"
    t.datetime "original_updated_at"
    t.string   "client_ip"
    t.string   "course_type"
    t.integer  "quantity"
    t.string   "course_unit"
    t.integer  "list_price"
    t.string   "currency"
    t.text     "price_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["user_id"], :name => "fk_user"
  add_index "courses", ["menu_id"], :name => "fk_menu"
  add_index "courses", ["recipe_id"], :name => "fk_recipe"

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "match_id"
    t.string   "title"
    t.text     "description"
    t.string   "entriable_type"
    t.integer  "entriable_id"
    t.integer  "total_votes"
    t.string   "status"
    t.integer  "votes_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "valid_total_votes"
    t.integer  "valid_votes_count"
  end

  add_index "entries", ["user_id"], :name => "fk_user"
  add_index "entries", ["match_id"], :name => "fk_match"
  add_index "entries", ["entriable_type"], :name => "i_entriable_type"
  add_index "entries", ["entriable_type", "entriable_id"], :name => "i_entriable"

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
    t.string   "client_ip"
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

  create_table "keepers", :force => true do |t|
    t.string   "username",   :limit => 64,                   :null => false
    t.string   "hashed_pwd",                                 :null => false
    t.boolean  "enabled",                  :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keepers_roles", :id => false, :force => true do |t|
    t.integer "role_id",   :null => false
    t.integer "keeper_id", :null => false
  end

  create_table "match_actors", :force => true do |t|
    t.integer  "match_id"
    t.integer  "user_id"
    t.string   "roles"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "match_actors", ["user_id"], :name => "fk_user"
  add_index "match_actors", ["match_id"], :name => "fk_match"

  create_table "matches", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "subject"
    t.string   "entriable_type"
    t.text     "description"
    t.string   "organiger_type"
    t.integer  "organiger_id"
    t.integer  "cover_photo_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "voting_start_at"
    t.datetime "voting_end_at"
    t.integer  "entries_per_player"
    t.integer  "entries_per_voter"
    t.integer  "votes_per_entry"
    t.integer  "votes_lower_limit"
    t.string   "voting_type"
    t.string   "self_vote"
    t.text     "any_else"
    t.string   "status"
    t.string   "privacy"
    t.integer  "photos_count"
    t.integer  "reviews_count"
    t.integer  "favorites_count"
    t.integer  "entries_count"
    t.integer  "awards_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photos_per_entry"
    t.integer  "chars_per_entry"
    t.integer  "winners_count"
    t.integer  "players_count"
    t.integer  "votes_count"
    t.integer  "tags_per_entry"
    t.integer  "awards_per_entry"
    t.integer  "awards_per_player"
    t.datetime "enrolling_start_at"
    t.datetime "enrolling_end_at"
    t.datetime "collecting_start_at"
    t.datetime "collecting_end_at"
    t.datetime "original_updated_at"
    t.string   "slogan"
    t.datetime "published_at"
    t.text     "rules"
    t.string   "is_draft"
    t.string   "client_ip"
    t.text     "awards_description"
  end

  add_index "matches", ["user_id"], :name => "fk_user"
  add_index "matches", ["entriable_type"], :name => "i_entriable_type"
  add_index "matches", ["organiger_type"], :name => "i_organiger_type"
  add_index "matches", ["organiger_type", "organiger_id"], :name => "i_organiger"

  create_table "menus", :force => true do |t|
    t.integer  "user_id"
    t.integer  "match_id"
    t.integer  "cover_photo_id"
    t.string   "title"
    t.text     "description"
    t.text     "any_else"
    t.string   "from_type"
    t.string   "from_where"
    t.string   "is_draft"
    t.datetime "published_at"
    t.string   "roles"
    t.string   "status"
    t.string   "privacy"
    t.datetime "original_updated_at"
    t.string   "client_ip"
    t.string   "meal_duration"
    t.string   "meal_kind"
    t.string   "meal_system"
    t.string   "meal_date"
    t.string   "meal_time"
    t.string   "meal_time_notes"
    t.integer  "place_id"
    t.string   "place_area"
    t.string   "place_subarea"
    t.string   "place_area_detail"
    t.string   "place_type"
    t.string   "place_title"
    t.text     "place_notes"
    t.integer  "number_of_persons"
    t.integer  "number_of_adults"
    t.integer  "number_of_children"
    t.text     "person_notes"
    t.integer  "total_amount"
    t.integer  "discount_amount"
    t.integer  "tip_amount"
    t.integer  "total_to_pay"
    t.integer  "total_per_person"
    t.string   "currency"
    t.text     "bill_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "menus", ["user_id"], :name => "fk_user"
  add_index "menus", ["match_id"], :name => "fk_match"

  create_table "newsletters", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.boolean  "sent",       :default => false, :null => false
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
    t.string   "content_type",         :limit => 100
    t.string   "filename"
    t.string   "path"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "photo_type"
    t.string   "client_ip"
    t.string   "related_subitem_type"
    t.integer  "related_subitem_id"
  end

  add_index "photos", ["user_id"], :name => "fk_user"
  add_index "photos", ["photoable_type"], :name => "pi_photoable_type"
  add_index "photos", ["user_id", "photoable_type"], :name => "i_user_photoable_type"
  add_index "photos", ["user_id", "photoable_type", "photoable_id"], :name => "i_user_photoable"
  add_index "photos", ["parent_id"], :name => "i_parent_photo"
  add_index "photos", ["photoable_type", "photoable_id"], :name => "pi_photoable"
  add_index "photos", ["related_subitem_type", "related_subitem_id"], :name => "i_subitem"
  add_index "photos", ["photoable_type", "photoable_id", "related_subitem_type"], :name => "i_photoable_subitem_type"
  add_index "photos", ["photoable_type", "photoable_id", "related_subitem_type", "related_subitem_id"], :name => "i_photoable_subitem"

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
    t.string   "client_ip"
  end

  add_index "profiles", ["user_id"], :name => "fk_user"

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
    t.string   "roles"
    t.datetime "original_updated_at"
    t.integer  "match_id"
    t.string   "common_title"
    t.string   "client_ip"
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
    t.text     "quotation"
    t.integer  "quotation_submitter_id"
    t.string   "client_ip"
  end

  add_index "reviews", ["reviewable_type", "reviewable_id"], :name => "pi_reviewable"
  add_index "reviews", ["reviewable_type"], :name => "pi_reviewable_type"
  add_index "reviews", ["user_id"], :name => "fk_user"
  add_index "reviews", ["user_id", "reviewable_type"], :name => "i_user_reviewable_type"
  add_index "reviews", ["user_id", "reviewable_type", "reviewable_id"], :name => "i_user_reviewable"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "scores", :force => true do |t|
    t.integer  "user_id"
    t.string   "scoreable_type"
    t.integer  "scoreable_id"
    t.string   "taste"
    t.string   "shape"
    t.string   "creative"
    t.string   "nutrition"
    t.string   "cost_performance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["user_id"], :name => "fk_user"
  add_index "scores", ["scoreable_type", "scoreable_id"], :name => "i_scoreable"
  add_index "scores", ["user_id", "scoreable_type", "scoreable_id"], :name => "i_user_scoreable"

  create_table "stories", :force => true do |t|
    t.integer  "user_id"
    t.string   "storyable_type"
    t.integer  "storyable_id"
    t.string   "story_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stories", ["user_id"], :name => "fk_user"
  add_index "stories", ["storyable_type", "storyable_id"], :name => "pi_storyable"
  add_index "stories", ["storyable_type"], :name => "pi_storyable_type"
  add_index "stories", ["user_id", "storyable_type", "storyable_id"], :name => "i_user_storyable"
  add_index "stories", ["user_id", "storyable_type"], :name => "i_user_storyable_type"

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
    t.string   "roles"
    t.string   "client_ip"
  end

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.string   "voteable_type"
    t.integer  "voteable_id"
    t.integer  "votes"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "votein_type"
    t.integer  "votein_id"
  end

  add_index "votes", ["user_id"], :name => "fk_user"
  add_index "votes", ["voteable_type"], :name => "i_voteable_type"
  add_index "votes", ["voteable_type", "voteable_id"], :name => "i_voteable"

  create_table "winners", :force => true do |t|
    t.integer  "match_id"
    t.integer  "award_id"
    t.string   "winnerable_type"
    t.integer  "winnerable_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "winners", ["match_id"], :name => "fk_match"
  add_index "winners", ["award_id"], :name => "fk_award"
  add_index "winners", ["match_id", "winnerable_type"], :name => "i_match_winnerable_type"
  add_index "winners", ["match_id", "winnerable_type", "winnerable_id"], :name => "i_match_winnerable"
  add_index "winners", ["winnerable_type", "winnerable_id"], :name => "i_winnerable"

end
