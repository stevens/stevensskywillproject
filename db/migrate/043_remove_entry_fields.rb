class RemoveEntryFields < ActiveRecord::Migration
  def self.up
  	remove_column :entries, :award_id
  end

  def self.down
  	add_column :entries, :award_id, :integer
  end
end
