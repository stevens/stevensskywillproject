class AddReviewFields < ActiveRecord::Migration
  def self.up
  	add_column :reviews, :quotation, :text
  	add_column :reviews, :quotation_submitter_id, :integer
  end

  def self.down
  	remove_column :reviews, :quotation
  	remove_column :reviews, :quotation_submitter_id
  end
end
