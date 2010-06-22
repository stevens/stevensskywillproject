module JudgesHelper

  def judge_groups(judgein)
    item_parents = judgein.invited_judge_categories

    items = item_parents[0].judges.find(:all, :order => 'user_id DESC')
    item_groups = []
    for item in items
      item_groups << item.user
    end
    item_groups
  end

  def judge_user_groups(judgein)
    item_parents = judgein.judge_categories

    item_groups = []
    i = 0
    for item_parent in item_parents
      item_groups << { :item_parent => item_parent, :items => [] }
      for item in item_parent.judges
        item_groups[i][:items] << item.user
      end
      i += 1
    end
    item_groups
  end

  def invited_judge_stats(judgein)
    stats = []
    judge_users = judge_groups(judgein)
    for user in judge_users
      ballots = judgein.ballots.find(:all, :conditions => { :user_id => user.id })
      stats << { :user => user, :ballots_count => ballots.size }
    end
    stats.sort! { |a, b| b[:ballots_count] <=> a[:ballots_count] }
  end

  def invited_judge_stats_groups(judgein, stats)
    vote_awards_count = vote_awards_count(judgein)
    groups = []
    groups << { :title => "已投票", :count => 0 }
    groups << { :title => "投满#{vote_awards_count}票", :count => 0 }
    groups << { :title => "未投满#{vote_awards_count}票", :count => 0 }
    groups << { :title => "未投票", :count => 0 }
    for stat in stats
      count = stat[:ballots_count]
      if count > 0
        groups[0][:count] += 1
        if count == vote_awards_count
          groups[1][:count] += 1
        elsif count < vote_awards_count && count > 0
          groups[2][:count] += 1
        end
      elsif count == 0
        groups[3][:count] += 1
      end
    end
    groups
  end
    
end
