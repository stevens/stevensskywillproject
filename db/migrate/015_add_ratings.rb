class AddRatings < ActiveRecord::Migration
  def self.up
	  create_table :ratings do |t|
	    t.references :user
	    t.integer :rating
	    t.string :rateable_type
	    t.integer :rateable_id
	    
			t.timestamps
	  end
	
	  add_index :ratings, [:user_id], :name => 'fk_ratings_user'
  end

  def self.down
  	drop_table :ratings
  end
end
