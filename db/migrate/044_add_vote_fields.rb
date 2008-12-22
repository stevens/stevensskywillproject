class AddVoteFields < ActiveRecord::Migration
  def self.up
  	add_column :votes, :votein_type, :string
  	add_column :votes, :votein_id, :integer
  end

  def self.down
  	remove_column :votes, :votein_type
  	remove_column :votes, :votein_id
  end
end
