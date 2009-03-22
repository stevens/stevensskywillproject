class Score < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :user
  belongs_to :scoreable, :polymorphic => true

end
