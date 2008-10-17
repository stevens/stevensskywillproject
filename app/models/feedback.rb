class Feedback < ActiveRecord::Base

	validates_presence_of     :submitter_name, :if => :submitter_is_not_user?, 
  													:message => "请#{INPUT_CN}你的名字"
	validates_presence_of     :submitter_email, :if => :submitter_is_not_user?, 
  													:message => "请#{INPUT_CN}你的#{EMAIL_ADDRESS_CN}"
	validates_format_of 			:submitter_email, :if => :submitter_is_not_user?, 
														:with => /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
														:message => "#{EMAIL_ADDRESS_CN}格式不正确"
  validates_length_of       :submitter_email, :if => :submitter_is_not_user?, 
  													:within => STRING_MIN_LENGTH_M..STRING_MAX_LENGTH_L,
  													:too_short => "字数太短，应该是#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_L}位",
  													:too_long => "字数太长，应该是#{STRING_MIN_LENGTH_M}到#{STRING_MAX_LENGTH_L}位"
  validates_length_of       :title, 
  													:within => STRING_MIN_LENGTH_S..STRING_MAX_LENGTH_M,
  													:too_short => "字数太短，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_M}位",
  													:too_long => "字数太长，应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_M}位"
  validates_length_of       :body, 
  													:within => TEXT_MIN_LENGTH_S..TEXT_MAX_LENGTH_S,
  													:too_short => "字数太短，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位",
  													:too_long => "字数太长，应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位"
  													
	protected
	
	def submitter_is_not_user?
		self.user_id ? false : true
	end

end
