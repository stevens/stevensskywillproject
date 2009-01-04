class AddMatchFields < ActiveRecord::Migration
  def self.up
  	add_column :matches, :photos_per_entry, :integer #参赛作品图片数量的下限要求
  	add_column :matches, :chars_per_entry, :integer #参赛作品字符数量的下限要求
  	add_column :matches, :winners_count, :integer
  	add_column :matches, :players_count, :integer
  	add_column :matches, :votes_count, :integer
  end

  def self.down
  	remove_column :matches, :photos_per_entry
  	remove_column :matches, :chars_per_entry
  	remove_column :matches, :winners_count
  	remove_column :matches, :players_count
  	remove_column :matches, :votes_count
  end
end
