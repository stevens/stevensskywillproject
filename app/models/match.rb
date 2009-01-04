class Match < ActiveRecord::Base
	
	acts_as_taggable
	
	belongs_to :user
	belongs_to :organiger, :polymorphic => true
	
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
	
	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"
	has_many :entries, :order => "created_at DESC"
	has_many :awards, :order => "level, created_at"
	has_many :votes, :dependent => :destroy, :as => :votein, :foreign_key => :votein_id, :order => "created_at DESC"
	has_many :winners, :order => "created_at"
	has_many :match_actors, :order => "created_at DESC"
	
	def accessible?
		true
	end
end
