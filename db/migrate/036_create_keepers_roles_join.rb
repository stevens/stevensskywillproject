class CreateKeepersRolesJoin < ActiveRecord::Migration
  def self.up
    create_table :keepers_roles, :id => false do |t|
      t.column :role_id, :integer, :null => false
      t.column :keeper_id, :integer, :null => false
    end
    admin_keeper = Keeper.create(:username => 'Admin',
      :password => 'admin', :password_confirmation => 'admin')
    admin_role = Role.find_by_name('Administrator')
    admin_keeper.roles << admin_role
  end
  def self.down
    drop_table :keepers_roles
    Keeper.find_by_username('Admin').destroy
  end
end
