class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
			t.references :user
			t.references :match
			t.references :award
			t.string :title
			t.text :description
			t.string :entriable_type
			t.integer :entriable_id
			t.integer :total_votes
			t.string :status
			
			t.integer :votes_count
			
      t.timestamps
    end
    
    add_index :entries, [:user_id], :name => 'fk_user'
    add_index :entries, [:match_id], :name => 'fk_match'
    add_index :entries, [:award_id], :name => 'fk_award'
    add_index :entries, [:entriable_type], :name => 'i_entriable_type'
    add_index :entries, [:entriable_type, :entriable_id], :name => 'i_entriable'
  end

  def self.down
    drop_table :entries
  end
end
