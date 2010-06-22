class BallotResult < ActiveRecord::Base
	
  belongs_to :resultin, :polymorphic => true
  belongs_to :resultfor, :polymorphic => true

  def duplicated?
    BallotResult.find(:first, :conditions => { :resultin_type => self.resultin_type, :resultin_id => self.resultin_id,
                                              :resultfor_type => self.resultfor_type, :resultfor_id => self.resultfor_id })
  end

  def resultfor_stats
    ActiveSupport::JSON.decode(self.result_content)['resultfor_stats']
  end

  def resultable_stats
    ActiveSupport::JSON.decode(self.result_content)['resultable_stats']
  end

end
