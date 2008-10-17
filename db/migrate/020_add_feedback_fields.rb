class AddFeedbackFields < ActiveRecord::Migration
  def self.up
  	add_column :feedbacks, :submitter_type, :string
  	add_column :feedbacks, :submitter_name, :string
  	add_column :feedbacks, :submitter_email, :string
  end

  def self.down
  	remove_column :feedbacks, :submitter_type
  	remove_column :feedbacks, :submitter_name
  	remove_column :feedbacks, :submitter_email 
  end
end
