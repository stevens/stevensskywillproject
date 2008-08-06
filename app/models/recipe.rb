class Recipe < ActiveRecord::Base
	include ApplicationHelper
	
	acts_as_ferret :fields => [:title, :description]
	acts_as_taggable
	acts_as_rateable
	
	belongs_to :user
	has_many :photos, :order => "created_at"
	has_many :reviews, :order => "updated_at DESC"
	
	validates_presence_of     :title, :description,
  													:message => "这一项是#{REQUIRED_CN}"
  validates_length_of       :title,    
  													:within => STRING_MIN_LENGTH_S..STRING_MAX_LENGTH_M,
  													:too_short => "字数太短，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_M}位",
  													:too_long => "字数太长，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_M}位"
  validates_length_of       :description,    
  													:within => TEXT_MIN_LENGTH_S..TEXT_MAX_LENGTH_S,
  													:too_short => "字数太短，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位",
  													:too_long => "字数太长，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位"
  validates_length_of       :ingredients, :directions, :tips,    
  													:maximum => TEXT_MAX_LENGTH_L,
  													:too_long => "字数太长，最多不应该超过#{TEXT_MAX_LENGTH_L}位"
  
  def description_summary
  	text_summary(description, TEXT_SUMMARY_LENGTH_M)
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
  
end
