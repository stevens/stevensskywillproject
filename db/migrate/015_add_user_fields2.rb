class AddUserFields2 < ActiveRecord::Migration
  def self.up
		add_column :users, :latest_loggedin_at, :datetime
		add_column :users, :login_count, :integer
  end

  def self.down
  	remove_column :users, :latest_loggedin_at
  	remove_column :users, :login_count
  end
end
