class AddSomeIndexes < ActiveRecord::Migration
  def self.up
  	add_index :codes, [:codeable_type], :name => 'pi_codeable_type'
  	add_index :counters, [:countable_type, :countable_id], :name => 'pi_countable'
  	add_index :counters, [:countable_type], :name => 'pi_countable_type'
  	add_index :photos, [:photoable_type, :photoable_id], :name => 'pi_photoable'
  	add_index :photos, [:photoable_type], :name => 'pi_photoable_type'
  	add_index :ratings, [:rateable_type, :rateable_id], :name => 'pi_rateable'
  	add_index :ratings, [:rateable_type], :name => 'pi_rateable_type'
  	add_index :reviews, [:reviewable_type, :reviewable_id], :name => 'pi_reviewable'
  	add_index :reviews, [:reviewable_type], :name => 'pi_reviewable_type'
  	add_index :taggings, [:taggable_type, :taggable_id], :name => 'pi_taggable'
  	add_index :taggings, [:taggable_type], :name => 'pi_taggable_type'
  	add_index :taggings, [:tag_id], :name => 'fk_tag'
  end

  def self.down
  	remove_index :codes, :name => 'pi_codeable_type'
  	remove_index :counters, :name => 'pi_countable'
  	remove_index :counters, :name => 'pi_countable_type'
  	remove_index :photos, :name => 'pi_photoable'
  	remove_index :photos, :name => 'pi_photoable_type'
  	remove_index :ratings, :name => 'pi_rateable'
  	remove_index :ratings, :name => 'pi_rateable_type'
  	remove_index :reviews, :name => 'pi_reviewable'
  	remove_index :reviews, :name => 'pi_reviewable_type'
  	remove_index :taggings, :name => 'pi_taggable'
  	remove_index :taggings, :name => 'pi_taggable_type'
  	remove_index :taggings, :name => 'fk_tag'
  end
end
