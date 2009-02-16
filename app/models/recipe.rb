class Recipe < ActiveRecord::Base
	include ApplicationHelper
	include ReviewsHelper
	
	acts_as_taggable
	acts_as_rateable :average => true
	
	belongs_to :user
	
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
	
	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"	
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"
	has_many :entries, :dependent => :destroy, :as => :entriable, :foreign_key => :entriable_id, :order => "created_at DESC"
	
	validates_presence_of     :title, :difficulty, :description, :ingredients, :directions, :from_type, :privacy,
  													:message => "这一项是#{REQUIRED_CN}"
	validates_presence_of     :from_where, :if => :from_where_required?, 
  													:message => "请#{INPUT_CN}#{RECIPE_CN}的#{FROM_WHERE_CN}"
	validates_inclusion_of 		:from_where, :if => :from_where_not_required?, 
														:in => %w( ), 
														:message => "请不要#{INPUT_CN}#{RECIPE_CN}的#{FROM_WHERE_CN}"
  validates_length_of       :title,    
  													:within => 2..STRING_MAX_LENGTH_M,
  													:too_short => "字数太短，应该是2到#{STRING_MAX_LENGTH_M}位",
  													:too_long => "字数太长，应该是2到#{STRING_MAX_LENGTH_M}位"
  validates_length_of       :common_title, 
  													:maximum => STRING_MAX_LENGTH_M,
  													:too_long => "字数太长，最多不应该超过#{STRING_MAX_LENGTH_M}位"
  validates_length_of       :description,    
  													:within => TEXT_MIN_LENGTH_S..TEXT_MAX_LENGTH_S,
  													:too_short => "字数太短，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位",
  													:too_long => "字数太长，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位"
  validates_length_of       :ingredients, :directions, 
  													:within => TEXT_MIN_LENGTH_S..TEXT_MAX_LENGTH_L,
  													:too_short => "字数太短，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_L}位",
  													:too_long => "字数太长，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_L}位"
  validates_length_of       :tips, :any_else,     
  													:maximum => TEXT_MAX_LENGTH_L,
  													:too_long => "字数太长，最多不应该超过#{TEXT_MAX_LENGTH_L}位"
  validates_length_of       :yield, 
  													:maximum => STRING_MAX_LENGTH_M,
  													:too_long => "字数太长，最多不应该超过#{STRING_MAX_LENGTH_M}位"
  validates_length_of       :video_url, :from_where, 
  													:maximum => TEXT_MAX_LENGTH_S,
  													:too_long => "字数太长，最多不应该超过#{TEXT_MAX_LENGTH_S}位"
  
  def publishable?
  	(is_draft == '1' && cover_photo_id && status.to_i >= 1) ? true : false
  end
  
  def published?
  	(is_draft == '0' && !published_at.nil?) ? true : false
  end
  
  def entriable?
  	(is_draft == '0' && privacy == '10') ? true : false
  end
  
  def entrying?
  	if entriable? && !match_id.nil? && (match = Match.find_by_id(match_id))
  		(match.doing?(Time.now) && match.find_entry(self)) ? true : false
  	end
  end

  def entried?
  	if entriable? && !match_id.nil? && (match = Match.find_by_id(match_id))
  		match.find_entry(self) ? true : false
  	end
  end
  
  def draft_selectable?
  	(cover_photo_id && !entrying?) ? true : false
  end
  
  def accessible?(someuser = nil)
  	if someuser
  		if someuser == user
  			true
  		else
  			(is_draft == '0' && privacy <= '11') ? true : false
  		end
  	else
  		(is_draft == '0' && privacy == '10') ? true : false
  	end
  end
  
  def description_summary
  	text_summary(description)
  end
	
	def prep_time_display
		if prep_time
			h = second_to_hms(prep_time)[:h]
			m = second_to_hms(prep_time)[:m]
			s = second_to_hms(prep_time)[:s]
		else
			h = 0
			m = 0
			s = 0
		end
		{:h => h, :m => m, :s => s}
	end
	
	def cook_time_display
		if cook_time
			h = second_to_hms(cook_time)[:h]
			m = second_to_hms(cook_time)[:m]
			s = second_to_hms(cook_time)[:s]
		else
			h = 0
			m = 0
			s = 0
		end
		{:h => h, :m => m, :s => s}
	end
	
	def get_status
  	if title && !title.blank? &&
  		 description && !description.blank? &&
  		 from_type && !from_type.blank? && 
  		 privacy && !privacy.blank?
  		if ingredients && !ingredients.blank? &&
  			 directions && !directions.blank? &&
  			 difficulty && !difficulty.blank?
				if prep_time && !prep_time.blank? &&
					 cook_time && !cook_time.blank? &&
					 cost && !cost.blank? &&
					 self.yield && !self.yield.blank?
					if tips && !tips.blank? &&
						 video_url && !video_url.blank? &&
						 any_else && !any_else.blank?
						'3'
					else
						'2'
					end
				else
					'1'
				end
			else
				'0'
			end
		end	
	end

	def get_is_draft
		if !cover_photo_id || status.to_i < 1
			'1'
		else
			is_draft
		end
	end
	
	def get_published_at
  	if !published_at && privacy != '90' && is_draft != '1'
  		Time.now
  	else
  		published_at
  	end
	end
	
	def latest_reviewed_at(user = nil, created_at_from = nil, created_at_to = nil, reviewable_conditions = nil)
		if reviews = reviews_for(user, 'Recipe', review_conditions('Recipe', self.id, created_at_from, created_at_to), reviewable_conditions, 1)
			reviews[0].created_at
		end
	end
	
	protected
	
	def from_where_required?
		from_type != '1' && (from_where.nil? || from_where.blank?)
	end
	
	def from_where_not_required?
		from_type == '1' && !from_where.blank?
	end
  
end
