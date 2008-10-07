class AddRecipeFields4 < ActiveRecord::Migration
  def self.up
  	add_column :recipes, :published_at, :datetime
  	add_column :recipes, :is_draft, :string
  end

  def self.down
  	remove_column :recipes, :published_at
  	remove_column :recipes, :is_draft
  end
end
