class AddFkRecipesUser < ActiveRecord::Migration
  def self.up
  	add_index :recipes, [:user_id], :name => 'fk_user'
  end

  def self.down
  	remove_index :recipes, :name => :fk_user
  end
end
