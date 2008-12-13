class Entry < ActiveRecord::Base

	belongs_to :user
	belongs_to :match, :counter_cache => true
	belongs_to :entriable, :polymorphic => true
	
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
	
	has_many :votes, :dependent => :destroy, :as => :voteable, :foreign_key => :voteable_id, :order => "created_at DESC"
	
end
