class CreateAwards < ActiveRecord::Migration
  def self.up
    create_table :awards do |t|
			t.references :user
			t.references :match
			t.string :title
			t.text :description
			t.integer :order
			t.string :quota
			
			t.string :prize_title
			t.text :prize_description
			t.string :prize_value
			
			t.integer :cover_photo_id
			
			t.string :status
			
			t.integer :photos_count
			t.integer :reviews_count
			
      t.timestamps
    end
    
    add_index :awards, [:user_id], :name => 'fk_user'
    add_index :awards, [:match_id], :name => 'fk_match'
  end

  def self.down
    drop_table :awards
  end
end
