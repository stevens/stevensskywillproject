class Ballot < ActiveRecord::Base

  include ApplicationHelper

  belongs_to :user
  belongs_to :ballotin, :polymorphic => true
  belongs_to :ballotfor, :polymorphic => true

	validates_presence_of :ballot_content,
                          :message => "这一项是#{REQUIRED_CN}"
  validates_length_of :remark,
                        :maximum => TEXT_MAX_LENGTH_S,
                        :too_long => "字数太长, 最多不应该超过#{TEXT_MAX_LENGTH_S}位"

  def duplicated?
    Ballot.find(:first, :conditions => { :user_id => self.user_id,
                                        :ballotin_type => self.ballotin_type, :ballotin_id => self.ballotin_id,
                                        :ballotfor_type => self.ballotfor_type, :ballotfor_id => self.ballotfor_id })
  end

  def ballotables
    items = ActiveSupport::JSON.decode(self.ballot_content)['ballotables']
    results = []
    if items && items.size > 0
      result_model = model_for(items[0]['type'])
      for item in items
        if result = result_model.find_by_id(item['id'])
          results << result
        end
      end
    end
    results
  end
end
