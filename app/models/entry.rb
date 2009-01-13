class Entry < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :match
	belongs_to :entriable, :polymorphic => true
	
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
	
	has_many :votes, :dependent => :destroy, :as => :voteable, :foreign_key => :voteable_id, :order => "created_at DESC"
	has_many :winners, :dependent => :destroy, :as => :winnerable, :foreign_key => :winnerable_id
	
	validates_presence_of	:match_id,
												:message => "还没有选择要参加的#{MATCH_CN}"
  # validates_length_of :title, 
  # 										:maximum => STRING_MAX_LENGTH_M,
  # 										:too_long => "字数太长，最多不应该超过#{STRING_MAX_LENGTH_M}位"
  # validates_length_of	:description, 
  # 										:maximum => TEXT_MAX_LENGTH_S,
  # 										:too_long => "字数太长，最多不应该超过#{TEXT_MAX_LENGTH_S}位"
	
end
