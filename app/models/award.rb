class Award < ActiveRecord::Base

	belongs_to :match, :counter_cache => true
	
	# has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
	
	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"
	has_many :winners, :order => "created_at"
end
