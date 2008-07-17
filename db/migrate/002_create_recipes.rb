class CreateRecipes < ActiveRecord::Migration
  def self.up
    create_table :recipes do |t|
      t.references :user
      t.string :title
      t.text :description
      t.text :ingredients
      t.text :directions
      t.text :tips
      
      t.integer :cover_photo_id #

      t.timestamps
    end
  end

  def self.down
    drop_table :recipes
  end
end
