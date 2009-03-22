class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.references :user
      t.references :match
      t.integer :cover_photo_id
      
      t.string :title
      t.text :description
      t.text :any_else

      t.string :from_type
      t.string :from_where

      t.string :is_draft
      t.datetime :published_at

      t.string :roles
      t.string :status
      t.string :privacy
      t.datetime :original_updated_at
      t.string :client_ip

      t.string :meal_duration
      t.string :meal_kind
      t.string :meal_system

      t.string :meal_date
      t.string :meal_time
      t.string :meal_time_notes

      t.integer :place_id
      t.string :place_area
      t.string :place_subarea
      t.string :place_area_detail
      t.string :place_type
      t.string :place_title
      t.text :place_notes

      t.integer :number_of_persons
      t.integer :number_of_adults
      t.integer :number_of_children
      t.text :person_notes

      t.integer :total_amount
      t.integer :discount_amount
      t.integer :tip_amount
      t.integer :total_to_pay
      t.integer :total_per_person
      t.string :currency
      t.text :bill_notes

      t.timestamps
    end

    add_index :menus, [:user_id], :name => 'fk_user'
    add_index :menus, [:match_id], :name => 'fk_match'
  end

  def self.down
    drop_table :menus
  end
end
