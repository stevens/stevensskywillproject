class Judge < ActiveRecord::Base

	belongs_to :user
  belongs_to :judge_category
  belongs_to :judgein, :polymorphic => true

  def duplicated?
    Judge.find(:first, :conditions => { :user_id => self.user_id, :judge_category_id => self.judge_category_id,
                                        :judgein_type => self.judgein_type, :judgein_id => self.judgein_id })
  end

end
