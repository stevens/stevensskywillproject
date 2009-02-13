module VotesHelper

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
end
