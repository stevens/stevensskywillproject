module MatchActorsHelper
	
	def match_actor_role_conditions(actor_role)
		actor_role_code = Code.find_by_codeable_type_and_name('match_actor_role', actor_role).code
		"match_actors.roles = #{actor_role_code}"
	end

  def joined_matches(match_actors, match_status = nil)
  	matches = []
  	for ma in match_actors
  		if match_status
  			matches << ma.match if (ma.match && ma.match.accessible? && ma.match.status == match_status)
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
