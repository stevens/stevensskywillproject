class AddUserFields < ActiveRecord::Migration
  def self.up
    add_column :users, :password_reset_code, :string, :limit => 40
    add_column :users, :enabled, :boolean, :default => true  
  end

  def self.down
  	remove_column :users, :password_reset_code
  	remove_column :users, :enabled
  end
end
