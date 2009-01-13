module MatchesHelper
	
	def matches_for(user = nil, match_conditions = match_conditions, limit = nil, order = 'start_at DESC, end_at DESC')
		if user
			user.matches.find(:all, :limit => limit, :order => order, 
												:conditions => match_conditions)
		else
			Match.find(:all, :limit => limit, :order => order, 
								 :conditions => match_conditions)
		end
	end
	
  def match_conditions(status = nil, privacy = nil, created_at_from = nil, created_at_to = nil)
  	conditions = ["matches.title IS NOT NULL", 
  								"matches.title <> ''", 
  								"matches.description IS NOT NULL", 
  								"matches.description <> ''", 
  								"matches.start_at IS NOT NULL", 
  								"matches.end_at IS NOT NULL", 
  								"matches.id <> 999"]
  	conditions << "matches.status = #{status}" if status
  	conditions << "matches.privacy <= #{privacy}" if privacy
		conditions << "matches.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "matches.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end
	
end
