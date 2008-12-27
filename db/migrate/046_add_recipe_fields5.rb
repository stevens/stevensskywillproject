class AddRecipeFields5 < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :roles, :string
  	add_column :recipes, :original_updated_at, :datetime
  end

  def self.down
  	remove_column :recipes, :roles
  	remove_column :recipes, :original_updated_at
  end
end
