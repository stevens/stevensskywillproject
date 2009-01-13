module MatchActorsHelper

  def joined_matches(match_actors)
  	matches = []
  	for ma in match_actors
  		matches << ma.match
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
