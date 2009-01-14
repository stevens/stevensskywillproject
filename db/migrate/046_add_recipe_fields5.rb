class AddRecipeFields5 < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :roles, :string
  	add_column :recipes, :original_updated_at, :datetime
  	add_column :recipes, :match_id, :integer
  	add_column :recipes, :common_title, :string
  end

  def self.down
  	remove_column :recipes, :roles
  	remove_column :recipes, :original_updated_at
  	remove_column :recipes, :match_id
  	remove_column :recipes, :common_title
  end
end
