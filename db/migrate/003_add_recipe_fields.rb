class AddRecipeFields < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :difficulty, :string
  	add_column :recipes, :prep_time, :integer
  	add_column :recipes, :cook_time, :integer
  	add_column :recipes, :yield, :string
  end

  def self.down
  	remove_column :recipes, :difficulty
  	remove_column :recipes, :prep_time
  	remove_column :recipes, :cook_time
  	remove_column :recipes, :yield
  end
end
