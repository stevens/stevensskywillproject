class Message < ActiveRecord::Base
  has_many :usermessages
  has_many :recipients, :through => :usermessages
  has_many :senders, :through => :usermessages
  #before_create :prepare_copies

  attr_accessor :from, :to
  attr_accessible :title, :comment, :from, :to


  validates_presence_of   :title, :comment,	:message => "这一项是#{REQUIRED_CN}"

  validates_length_of     :title,
  													:within => 2..STRING_MAX_LENGTH_S,
  													:too_short => "标题字数太短, 应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_S}位",
  													:too_long => "标题字数太长, 应该是#{STRING_MIN_LENGTH_S}到#{STRING_MAX_LENGTH_S}位"

  validates_length_of     :comment,
  													:within => TEXT_MIN_LENGTH_S..TEXT_MAX_LENGTH_S,
  													:too_short => "内容字数太短, 应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位",
  													:too_long => "内容字数太长, 应该是#{TEXT_MIN_LENGTH_S}到#{TEXT_MAX_LENGTH_S}位"


  def prepare_copies
    @usermessage = Usermessage.new(:sender_id => from, :recipient_id => to)
    @usermessage.save
  end

  def self.setup_msg(message,from,to)
    transaction do
      message.save
      if !message.id.blank?
        Usermessage.create(:message_id=>message.id,:sender_id=>from,:recipient_id=>to, :sender_status=>1, :recipient_status=>1, :ifread=>1)
      end
    end
  end

end
