class CreateMatchActors < ActiveRecord::Migration
  def self.up
    create_table :match_actors do |t|
			t.references :match
			t.references :user
			t.string :roles
			t.string :status
			
      t.timestamps
    end
    
    add_index :match_actors, [:user_id], :name => 'fk_user'
    add_index :match_actors, [:match_id], :name => 'fk_match'
  end

  def self.down
    drop_table :match_actors
  end
end
