class Partner < ActiveRecord::Base

  acts_as_taggable

	belongs_to :user

	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id

	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"

  has_many :partnerships, #合作伙伴关系
            :dependent => :destroy,
            :as => :partyb,
            :foreign_key => :partyb_id,
            :order => "created_at DESC"

	def accessible?(someuser = nil)
    true
	end
  
end