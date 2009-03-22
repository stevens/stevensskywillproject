class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.references :user
      t.references :menu
      t.references :recipe
      t.integer :cover_photo_id

      t.string :title
      t.string :common_title
      t.text :description
      t.text :any_else

      t.integer :sequence
      t.string :roles
      t.string :status
      t.string :privacy
      t.datetime :original_updated_at
      t.string :client_ip

      t.string :course_type
      t.integer :quantity
      t.string :course_unit
      
      t.integer :list_price
      t.string :currency
      t.text :price_notes

      t.timestamps
    end

    add_index :courses, [:user_id], :name => 'fk_user'
    add_index :courses, [:menu_id], :name => 'fk_menu'
    add_index :courses, [:recipe_id], :name => 'fk_recipe'
  end

  def self.down
    drop_table :courses
  end
end
