class AddPhotoFields < ActiveRecord::Migration
  def self.up
  	add_column :photos, :photo_type, :string
  end

  def self.down
  	remove_column :photos, :photo_type
  end
end
