class AddEntryFields < ActiveRecord::Migration
  def self.up
    add_column :entries, :valid_total_votes, :integer
    add_column :entries, :valid_votes_count, :integer
  end

  def self.down
    remove_column :entries, :valid_total_votes
    remove_column :entries, :valid_votes_count
  end
end
