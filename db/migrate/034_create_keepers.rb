class CreateKeepers < ActiveRecord::Migration
  def self.up
    create_table :keepers do |t|
      t.string :username, :limit=>64, :null=>false
      t.string :hashed_pwd, :null=>false
      t.boolean :enabled, :default=>true, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :keepers
  end
end
