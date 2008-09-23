class AddRecipeFields3 < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :any_else, :text
  end

  def self.down
  	remove_column :recipes, :any_else
  end
end
