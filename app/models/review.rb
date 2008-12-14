class Review < ActiveRecord::Base
	include ApplicationHelper
	
	belongs_to :user
	belongs_to :reviewable, :polymorphic => true
	
	validates_presence_of     :review,
  													:message => "这一项是#{REQUIRED_CN}"
  # validates_length_of       :title,    
  # 													:within => STRING_MIN_LENGTH_S..STRING_MAX_LENGTH_M,
  # 													:too_short => "字数太短，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_M}位",
  # 													:too_long => "字数太长，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_M}位"
  validates_length_of       :review,    
  													:within => 3..TEXT_MAX_LENGTH_L,
  													:too_short => "字数太短，应该是3到#{TEXT_MAX_LENGTH_M}位",
  													:too_long => "字数太长，应该是3到#{TEXT_MAX_LENGTH_M}位"

  def review_summary
  	text_summary(review, TEXT_SUMMARY_LENGTH_M)
  end
  									
end
