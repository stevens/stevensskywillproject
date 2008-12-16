class Match < ActiveRecord::Base
	
	acts_as_taggable
	
	belongs_to :user
	belongs_to :organiger, :polymorphic => true
	
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
	
	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"
	has_many :entries, :order => "total_votes, votes_count, created_at DESC"
	has_many :awards, :order => "order, created_at"
end