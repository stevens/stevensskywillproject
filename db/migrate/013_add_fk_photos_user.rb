class AddFkPhotosUser < ActiveRecord::Migration
  def self.up
  	add_index :photos, [:user_id], :name => 'fk_photos_user'
  end

  def self.down
  	remove_index :photos, :name => :fk_photos_user
  end
end
