class AddRecipeFields3 < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :any_else, :text
  	add_column :recipes, :view_count, :integer
  end

  def self.down
  	remove_column :recipes, :any_else
  	remove_column :recipes, :view_count
  end
end
