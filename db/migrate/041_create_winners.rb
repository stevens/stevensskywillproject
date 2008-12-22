class CreateWinners < ActiveRecord::Migration
  def self.up
    create_table :winners do |t|
			t.references :match
			t.references :award
			t.string :winnerable_type
			t.integer :winnerable_id
			t.string :status
			
      t.timestamps
    end
    
    add_index :winners, [:match_id], :name => 'fk_match'
    add_index :winners, [:award_id], :name => 'fk_award'
    add_index :winners, [:match_id, :winnerable_type], :name => 'i_match_winnerable_type'
    add_index :winners, [:match_id, :winnerable_type, :winnerable_id], :name => 'i_match_winnerable'
    add_index :winners, [:winnerable_type, :winnerable_id], :name => 'i_winnerable'
  end

  def self.down
    drop_table :winners
  end
end
