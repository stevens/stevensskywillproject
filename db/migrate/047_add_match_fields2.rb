class AddMatchFields2 < ActiveRecord::Migration
  def self.up
  	add_column :matches, :slogan, :string #比赛口号
  	add_column :matches, :tags_per_entry, :integer #每个参赛作品的标签数量要求
  	add_column :matches, :awards_per_entry, :integer #每个参赛作品的可获奖数量要求
  	add_column :matches, :awards_per_player, :integer #每个参赛选手的可获奖数量要求
  	add_column :matches, :enrolling_start_at, :datetime
  	add_column :matches, :enrolling_end_at, :datetime
  	add_column :matches, :collecting_start_at, :datetime
  	add_column :matches, :collecting_end_at, :datetime
  	add_column :matches, :original_updated_at, :datetime
  	add_column :matches, :published_at, :datetime
  	add_column :matches, :rules, :text
  	add_column :matches, :is_draft, :string
  end

  def self.down
  	remove_column :matches, :slogan
  	remove_column :matches, :tags_per_entry
  	remove_column :matches, :awards_per_entry
  	remove_column :matches, :awards_per_player
  	remove_column :matches, :enrolling_start_at
  	remove_column :matches, :enrolling_end_at
  	remove_column :matches, :collecting_start_at
  	remove_column :matches, :collecting_end_at
  	remove_column :matches, :original_updated_at
  	remove_column :matches, :published_at
  	remove_column :matches, :rules
  	remove_column :matches, :is_draft
  end
end
