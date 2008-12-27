class AddRecipeFields1 < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :roles, :string
  end

  def self.down
  	remove_column :recipes, :roles
  end
end
