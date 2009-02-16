module VotesHelper

  def voters_for(votes)
    voters = []
    for vote in votes
      voters << vote.user
    end
    voters
  end

  def voteables_for(votes)
  	voteables = []
  	for vote in votes
  		voteables << vote.voteable
  	end
  	voteables
  end
  
  def total_votes(voteable)
    votes_count = voteable.votes_count
    if votes_count && votes_count > 0
      voteable.votes.sum('votes')
    else
      0
    end
  end

  def highest_voted_items(voteables, votes_lower_limit = nil)
    items = []
    for voteable in voteables
      votes_count = voteable.votes_count
      if votes_count && votes_count > 0
        if votes_lower_limit && votes_lower_limit > 0
          items << voteable if votes_count > votes_lower_limit
        else
          items << voteable
        end
      end
    end
    items.sort { |a,b| [ total_votes(b), b.votes_count ] <=> [ total_votes(a), a.votes_count ] }
  end

  def valid_votes(voteable, same_ip_voters_limit)
    valid_total_votes = 0
    valid_votes_count = 0
    votes = voteable.votes.find(:all, :order => 'votes DESC')
    voters = voters_for(votes)
    same_ip_voters_set = voters.group_by { |voter| (voter.client_ip) }.sort { |a, b| b[1].size <=> a[1].size }
    for same_ip_voters in same_ip_voters_set
      same_ip_voters_count = same_ip_voters[1].size
      if same_ip_voters_count > 0
        if same_ip_voters_count <= same_ip_voters_limit
          valid_votes_count += same_ip_voters_count
        else
          valid_votes_count += same_ip_voters_limit
       end
        valid_total_votes += valid_same_ip_voters_votes(voteable, same_ip_voters[0], same_ip_voters_limit)
      end
    end
    [valid_total_votes, valid_votes_count]
  end

  def valid_same_ip_voters_votes(voteable, same_ip, limit)
    if same_ip.blank?
      conditions = "users.client_ip IS NULL OR users.client_ip = ''"
    else
      conditions = "users.client_ip LIKE '%#{same_ip}%'"
    end
    valid_voters_votes = voteable.votes.find(:all, :limit => limit, :order => 'votes.votes DESC',
                                            :joins => "JOIN users ON votes.user_id = users.id",
                                            :conditions => conditions)
    valid_total_votes = 0
    for vote in valid_voters_votes
      valid_total_votes += vote.votes
    end
    valid_total_votes
  end
end
