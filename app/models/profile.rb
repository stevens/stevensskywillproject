class Profile < ActiveRecord::Base

	belongs_to :user

  validates_length_of :blog,
                        :maximum => STRING_MAX_LENGTH_M,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_M}位"
  validates_length_of :intro,
                        :maximum => TEXT_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{TEXT_MAX_LENGTH_S}位"
  validates_length_of :taobao,
                        :maximum => STRING_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_S}位"
  validates_length_of :shipping_name,
                        :maximum => STRING_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_S}位"
	validates_format_of :shipping_email,
												:with => /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
												:message => "#{EMAIL_ADDRESS_CN}格式不正确",
                        :allow_nil => true,
                        :allow_blank => true
  validates_length_of :shipping_mobile,
                        :maximum => STRING_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_S}位"
  validates_length_of :shipping_phone,
                        :maximum => STRING_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_S}位"
  validates_length_of :shipping_postcode,
                        :maximum => STRING_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{STRING_MAX_LENGTH_S}位"
  validates_length_of :shipping_address,
                        :maximum => TEXT_SUMMARY_LENGTH_M,
                        :too_long => "字数太长, 最多不应该超过#{TEXT_SUMMARY_LENGTH_M}位"

end
