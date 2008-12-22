class RemoveAwardFields < ActiveRecord::Migration
  def self.up
  	remove_column :awards, :user_id
  end

  def self.down
  	add_column :awards, :user_id, :integer
  end
end
