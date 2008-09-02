class AddRecipeFields2 < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :from_type, :string
  	add_column :recipes, :from_where, :text
  	add_column :recipes, :cost, :string
  	add_column :recipes, :video_url, :text
  	add_column :recipes, :status, :string
  	add_column :recipes, :privacy, :string
  end

  def self.down
  	remove_column :recipes, :from_type
  	remove_column :recipes, :from_where
  	remove_column :recipes, :cost
  	remove_column :recipes, :video_url
  	remove_column :recipes, :status
  	remove_column :recipes, :privacy
  end
end
