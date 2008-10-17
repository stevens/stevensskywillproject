class CreateReviews < ActiveRecord::Migration
	def self.up
	  create_table :reviews do |t|
	    t.references :user
	    t.string :title
	    t.text :review
	    t.string :reviewable_type
	    t.integer :reviewable_id
	    
			t.timestamps
	  end
	
	  add_index :reviews, [:user_id], :name => 'fk_user'
	end
	
	def self.down
	  drop_table :reviews
	end
end
