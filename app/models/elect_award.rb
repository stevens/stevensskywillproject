class ElectAward < ActiveRecord::Base

  include ApplicationHelper

  belongs_to :awardin, :polymorphic => true
  belongs_to :parent, :class_name => "ElectAward", :foreign_key => :parent_id

	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id

	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
#	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"

  has_many :childs, #子奖项
            :class_name => "ElectAward",
            :dependent => :destroy,
            :foreign_key => :parent_id,
            :order => "sequence"
  has_many :nominations, #奖项的提名
            :dependent => :destroy,
            :as => :nominatefor,
            :foreign_key => :nominatefor_id,
            :order => "created_at DESC"
  has_many :winners, #奖项的获奖
            :class_name => "ElectWinner",
            :dependent => :destroy,
            :as => :winnerfor,
            :foreign_key => :winnerfor_id,
            :order => "created_at DESC"
  has_many :ballots, #奖项的选票
            :dependent => :destroy,
            :as => :ballotfor,
            :foreign_key => :ballotfor_id,
            :order => "created_at DESC"
  has_many :ballot_results, #奖项的选票结果
            :dependent => :destroy,
            :as => :resultfor,
            :foreign_key => :resultfor_id,
            :order => "created_at DESC"

  def basic_info
    infos = []
    infos << "#{name_for(self.awardable_type)}类奖" if self.parent_id.blank?
		infos << (self.winner_quota.blank? ? '若干名' : "#{self.winner_quota}名")
    infos << Code.find_by_codeable_type_and_code('elect_mode', self.elect_mode).title if !self.elect_mode.blank?
    infos.join(' · ')
  end

end