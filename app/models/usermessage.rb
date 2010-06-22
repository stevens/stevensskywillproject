class Usermessage < ActiveRecord::Base
  belongs_to :message
  belongs_to :sender, :class_name=>"User"
  belongs_to :recipient, :class_name=>"User"
end
