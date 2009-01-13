module VotesHelper

  def voteables_for(votes)
  	voteables = []
  	for vote in votes
  		voteables << vote.voteable
  	end
  	voteables
  end

end
