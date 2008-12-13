class Favorite < ActiveRecord::Base

	belongs_to :user
	belongs_to :favorable, :polymorphic => true, :counter_cache => true

  validates_length_of       :note,  
  													:maximum => 500,
  													:too_long => "字数太长，最多不应该超过500位"
	
end
