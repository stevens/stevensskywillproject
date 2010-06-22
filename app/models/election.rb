class Election < ActiveRecord::Base

  acts_as_taggable

	belongs_to :user

	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id

	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"

  has_many :awards, #评选的奖项
            :class_name => "ElectAward",
            :dependent => :destroy,
            :as => :awardin,
            :foreign_key => :awardin_id,
            :order => "sequence"
  has_many :great_awards, #评选的大奖奖项
            :class_name => "ElectAward",
            :conditions => "award_type = 11",
            :as => :awardin,
            :foreign_key => :awardin_id,
            :order => "sequence"
  has_many :vote_awards, #评选的票选奖项
            :class_name => "ElectAward",
            :conditions => "elect_mode = 10",
            :as => :awardin,
            :foreign_key => :awardin_id,
            :order => "sequence"
  has_many :nominations, #评选的提名
            :dependent => :destroy,
            :as => :nominatein,
            :foreign_key => :nominatein_id,
            :order => "created_at DESC"
  has_many :winners, #评选的获奖
            :class_name => "ElectWinner",
            :dependent => :destroy,
            :as => :winnerin,
            :foreign_key => :winnerin_id,
            :order => "created_at DESC"
  has_many :judge_categories, #评选的评审类别
            :dependent => :destroy,
            :as => :judgein,
            :foreign_key => :judgein_id,
            :order => "sequence"
  has_many :invited_judge_categories, #评选的特邀评审类别
            :class_name => "JudgeCategory",
            :conditions => "judge_type = 10",
            :as => :judgein,
            :foreign_key => :judgein_id,
            :order => "sequence"
  has_many :judges, #评选的评审
            :dependent => :destroy,
            :as => :judgein,
            :foreign_key => :judgein_id,
            :order => "created_at DESC"
  has_many :partnership_categories, #评选的合作伙伴关系类别
            :dependent => :destroy,
            :as => :partya,
            :foreign_key => :partya_id,
            :order => "sequence"
  has_many :partnerships, #评选的合作伙伴关系
            :dependent => :destroy,
            :as => :partya,
            :foreign_key => :partya_id,
            :order => "created_at DESC"
  has_many :ballots, #评选的选票
            :dependent => :destroy,
            :as => :ballotin,
            :foreign_key => :ballotin_id,
            :order => "created_at DESC"
  has_many :ballot_results, #评选的选票结果
            :dependent => :destroy,
            :as => :resultin,
            :foreign_key => :resultin_id,
            :order => "created_at DESC"

	def accessible?(someuser = nil)
		id != 999 ? true : false
	end

  def is_status_of?(name)
    s = self.status.to_i
    case name
    when 'todo'
      s == 100
    when 'doing'
      s == 200
    when 'doing_any'
      s >= 200 && s < 300 && ![219, 229, 239].include?(s)
    when 'doing_nomination'
      s >= 211 && s < 219
    when 'doing_nomination_todo'
      s == 214
    when 'doing_nomination_doing'
      s == 215
    when 'doing_nomination_done'
      s == 216
    when 'doing_nomination_close'
      s == 219
    when 'doing_voting'
      s >= 221 && s < 229
    when 'doing_voting_todo'
      s == 221
    when 'doing_voting_doing'
      s == 222
    when 'doing_voting_done'
      s == 223
    when 'doing_voting_close'
      s == 229
    when 'doing_gala'
      s >= 231 && s < 239
    when 'doing_gala_todo'
      s == 231
    when 'doing_gala_doing'
      s == 232
    when 'doing_gala_done'
      s == 233
    when 'doing_gala_close'
      s == 239
    when 'done'
      s == 300
    when 'close'
      s == 900
    when 'close_any'
      [219, 229, 239, 900].include?(s)
    end
  end

  def vote_awards_count
    count = 0
    for award_category in self.vote_awards
      for award in award_category.childs
        count += 1
      end
    end
    count
  end

  def invited_judge_users
    users = []
    for invited_judge_category in self.invited_judge_categories
      for judge in invited_judge_category.judges
        users << judge.user
      end
    end
    users
  end

  def great_award_items
    items = []
    for great_award_category in self.great_awards
      items += great_award_category.childs
    end
    items
  end

  def great_award_winner_users
    users = []
    great_award_items = self.great_award_items
    for winner in self.winners
      users << winner.user if great_award_items.include?(winner.winnerfor)
    end
    users.uniq!
  end

  def great_award_winner_winnerables
    items = []
    great_award_items = self.great_award_items
    for winner in self.winners
      items << winner.winnerable if great_award_items.include?(winner.winnerfor)
    end
    items
  end

end
