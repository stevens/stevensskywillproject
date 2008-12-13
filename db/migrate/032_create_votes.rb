class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
			t.references :user
      t.string :voteable_type
      t.integer :voteable_id
			t.integer :votes
			t.string :status
			
      t.timestamps
    end
    
    add_index :votes, [:user_id], :name => 'fk_user'
    add_index :votes, [:voteable_type], :name => 'i_voteable_type'
    add_index :votes, [:voteable_type, :voteable_id], :name => 'i_voteable'
  end

  def self.down
    drop_table :votes
  end
end
