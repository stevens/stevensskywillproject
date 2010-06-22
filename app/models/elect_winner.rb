class ElectWinner < ActiveRecord::Base

	belongs_to :user
	belongs_to :winnerable, :polymorphic => true
  belongs_to :winnerin, :polymorphic => true
  belongs_to :winnerfor, :polymorphic => true

  validates_length_of :speech,
                        :maximum => TEXT_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{TEXT_MAX_LENGTH_S}位"

end
