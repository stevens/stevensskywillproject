class Vote < ActiveRecord::Base

	belongs_to :user
	belongs_to :voteable, :polymorphic => true
	belongs_to :votein, :polymorphic => true
	
end
