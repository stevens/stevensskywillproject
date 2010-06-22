module BallotsHelper

  def ballot_groups(ballotin, judge_user_groups, options = nil)
    if !options[:group_by].blank?
      case options[:group_by]
      when 'ballotable'
        item_grands = ballotin.vote_awards
        item_groups = []
        i = 0
        for item_grand in item_grands
          item_groups << { :item_grand => item_grand, :item_parents => [] }
          j = 0
          for item_parent in item_grand.childs
            item_groups[i][:item_parents] << { :item_parent => item_parent, :item_pairs => [] }
            item_pairs = []
            for ballot in item_parent.ballots
              for ballotable in ballot.ballotables
                item_pairs << { :ballotable => ballotable, :user => ballot.user, :remark => ballot.remark }
              end
            end
            item_pair_groups = item_pairs.group_by { |pair| (pair[:ballotable]) }.sort { |a, b| b[1].size <=> a[1].size }
            for item_pair_group in item_pair_groups
              item_groups[i][:item_parents][j][:item_pairs] << item_pair_group
            end
            j += 1
          end
          i += 1
        end
      when 'user'
        item_groups = []
        ballot_groups = ballotin.ballots.group_by { |ballot| ballot.user } #.sort { |a, b| b[1].size <=> a[1].size }
        invited_judge_users = ballotin.invited_judge_users
        great_award_winner_users = ballotin.great_award_winner_users
        great_award_winner_winnerables = ballotin.great_award_winner_winnerables

        for ballot_group in ballot_groups
          user = ballot_group[0]
          user_ballots = ballot_group[1]
          is_invited_judge = invited_judge_users.include?(user) ? true : false
          is_great_award_winner = great_award_winner_users.include?(user) ? true : false
          ballots_count = user_ballots.size
          right_ballots_count = 0
          for user_ballot in user_ballots
            for user_ballotable in user_ballot.ballotables
              right_ballots_count += 1 if great_award_winner_winnerables.include?(user_ballotable)
            end
          end
          item_groups << { :user => user, :is_invited_judge => is_invited_judge, :is_great_award_winner => is_great_award_winner, :ballots_count => ballots_count, :right_ballots_count => right_ballots_count }
        end
        item_groups = item_groups.sort_by { |item| [ -item[:ballots_count], -item[:right_ballots_count] ] }
      end
    else
      item_grands = ballotin.vote_awards
      item_groups = []
      i = 0
      for item_grand in item_grands
        item_groups << { :item_grand => item_grand, :item_parents => [] }
        j = 0
        for item_parent in item_grand.childs
          item_groups[i][:item_parents] << { :item_parent => item_parent, :item_pairs => [] }
          item_pairs = []
          for ballot in item_parent.ballots
            user = ballot.user
            remark = ballot.remark
            for ballotable in ballot.ballotables
              for judge_user_group in judge_user_groups
                judge_category = judge_user_group[:item_parent]
                judge_users = judge_user_group[:items]
                if judge_category.is_type_of?('user') || judge_users.include?(user)
                  item_pairs << { :ballotable => ballotable, :judge_category => judge_category, :user => user, :remark => remark }
                  break
                end
              end
            end
          end
          item_pair_groups = item_pairs.group_by { |pair| (pair[:ballotable]) }.sort { |a, b| b[1].size <=> a[1].size }
          for item_pair_group in item_pair_groups
            item_pair_group[1] = item_pair_group[1].group_by { |pair| (pair[:judge_category]) }.sort { |a, b| a[0].sequence <=> b[0].sequence }
            item_groups[i][:item_parents][j][:item_pairs] << item_pair_group
          end
          j += 1
        end
        i += 1
      end
    end
    item_groups
  end

  def ballot_stats(ballotfor, ballotable_pair_groups, judge_user_groups)
    ballot_stats = { :ballotfor => ballotfor, :ballotfor_stats => { :total => 0, :subtotals => [] }, :ballotable_stats_set => [] }
    ballotfor_stats = ballot_stats[:ballotfor_stats]
    ballotable_stats_set = ballot_stats[:ballotable_stats_set]
    for judge_user_group in judge_user_groups
      judge_category = judge_user_group[:item_parent]
      ballotfor_stats[:subtotals] << { :category => judge_category, :subtotal => 0 }
    end

    i = 0
    for ballotable_pair_group in ballotable_pair_groups
      ballotable = ballotable_pair_group[0]
      ballotable_stats_set << { :ballotable => ballotable, :total => 0, :percent => 0, :subtotals => [] }
      j = 0
      for judge_user_group in judge_user_groups
        judge_category = judge_user_group[:item_parent]
        ballotable_stats_set[i][:subtotals] << { :category => judge_category, :percent => 0, :subtotal => 0 }
        ballot_judge_user_groups = ballotable_pair_group[1]
        for ballot_judge_user_group in ballot_judge_user_groups
          ballot_judge_category = ballot_judge_user_group[0]
          if ballot_judge_category == judge_category
            ballot_judge_user_pairs = ballot_judge_user_group[1]
            for ballot_judge_user_pair in ballot_judge_user_pairs
              ballotable_stats_set[i][:subtotals][j][:subtotal] += 1
              ballotable_stats_set[i][:total] += 1
              ballotfor_stats[:subtotals][j][:subtotal] += 1
              ballotfor_stats[:total] += 1
            end
          end
        end
        j += 1
      end
      i += 1
    end
    i = 0
    for ballotable_stats in ballotable_stats_set
      j = 0
      for ballotable_stats_subtotal in ballotable_stats[:subtotals]
        weight = ballotable_stats_set[i][:subtotals][j][:category].weight.to_f
        percent = f(ballotable_stats_set[i][:subtotals][j][:subtotal] * 1.00 / ballotfor_stats[:subtotals][j][:subtotal], 4) * 100
        ballotable_stats_set[i][:subtotals][j][:percent] = percent
        ballotable_stats_set[i][:percent] += percent * weight
        j += 1
      end
      ballotable_stats_set[i][:percent] = f(ballotable_stats_set[i][:percent], 2)
      i += 1
    end
    ballot_stats[:ballotfor_stats] = ballotfor_stats
    ballot_stats[:ballotable_stats_set] = ballotable_stats_set.sort { |a, b| b[:percent] <=> a[:percent] }
    ballot_stats
  end
    
end
