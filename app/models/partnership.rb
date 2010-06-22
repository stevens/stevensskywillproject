class Partnership < ActiveRecord::Base

	belongs_to :partya, :polymorphic => true
  belongs_to :partyb, :polymorphic => true
  belongs_to :partnership_category, :polymorphic => true

end
