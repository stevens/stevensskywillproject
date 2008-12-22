class Winner < ActiveRecord::Base
	
	belongs_to :matches
	belongs_to :awards
	belongs_to :winnerable, :polymorphic => true
	
end
