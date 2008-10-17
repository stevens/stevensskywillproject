class AddSomeIndexes2 < ActiveRecord::Migration
  def self.up
  	add_index :photos, [:user_id, :photoable_type], :name => 'i_user_photoable_type'
  	add_index :photos, [:user_id, :photoable_type, :photoable_id], :name => 'i_user_photoable'
  	add_index :photos, [:parent_id], :name => 'i_parent_photo'
  	add_index :reviews, [:user_id, :reviewable_type], :name => 'i_user_reviewable_type'
  	add_index :reviews, [:user_id, :reviewable_type, :reviewable_id], :name => 'i_user_reviewable'
  	add_index :ratings, [:user_id, :rateable_type], :name => 'i_user_rateable_type'
  	add_index :taggings, [:tag_id, :taggable_type], :name => 'i_tag_taggable_type'
  end

  def self.down
		remove_index :photos, :name => 'i_user_photoable_type'
		remove_index :photos, :name => 'i_user_photoable'
		remove_index :photos, :name => 'i_parent_photo'
		remove_index :reviews, :name => 'i_user_reviewable_type'
		remove_index :reviews, :name => 'i_user_reviewable'
		remove_index :ratings, :name => 'i_user_rateable_type'
		remove_index :taggings, :name => 'i_tag_taggable_type'
  end
end
