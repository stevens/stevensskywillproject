class AddRecipeFields6 < ActiveRecord::Migration
  def self.up
    add_column :recipes, :tools, :text
  end

  def self.down
    remove_column :recipes, :tools
  end
end
