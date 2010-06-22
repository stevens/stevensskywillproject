class PartnershipCategory < ActiveRecord::Base

	belongs_to :partya, :polymorphic => true

  has_many :partnerships, :order => "sequence"

end
