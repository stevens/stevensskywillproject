module MatchActorsHelper

  def joined_matches(match_actors, match_status = nil)
  	matches = []
  	for ma in match_actors
  		if match_status
  			matches << ma.match if ma.match.status == match_status
  		else
  			matches << ma.match
  		end
  	end
  	matches
  end
  
  def match_actor_users(match_actors)
  	users = []
  	for ma in match_actors
  		users << ma.user
  	end
  	users
  end
end
