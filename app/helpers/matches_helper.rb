module MatchesHelper

	def accessible_matches(matches_set)
		matches = []
		for match in matches_set
			matches << match if match.accessible?
		end
		matches
	end

	def created_matches_set(user)
		accessible_matches(user.matches.find(:all))
	end
	
	def joined_matches_set(user, actor_role = nil)
		if actor_role.blank?
			match_actors = user.match_actors.find(:all)
		else
			match_actors = user.match_actors.find(:all, :conditions => { :roles => actor_role })
		end
		accessible_matches(joined_matches(match_actors))
	end
	
	def filtered_matches_set(user, filter = nil)
		if user
			case filter
			when 'created'
				matches = created_matches_set(user)
			when 'enrolled'
				matches = joined_matches_set(user, '1')
			when 'administered'
				matches = joined_matches_set(user, '2')
			else
				matches_set = created_matches_set(user) | joined_matches_set(user)
				if filter.blank?
					matches = matches_set
				else
					current = Time.now
					matches = []
					for match in matches_set
						case filter
						when 'todo'
							matches << match if match.todo?
						when 'doing'
							matches << match if match.doing?(current)
						when 'done'
							matches << match if match.done?
						end
					end
				end
			end
		else
			matches_set = Match.find(:all)
			if filter.blank?
				matches = matches_set
			else
				current = Time.now
				matches = []
				for match in matches_set
					case filter
					when 'todo'
						matches << match if match.todo?
					when 'doing'
						matches << match if match.doing?(current)
					when 'done'
						matches << match if match.done?
					end
				end
			end
		end
		matches.sort { |a, b| [ a.status, b.start_at, b.end_at, b.created_at ] <=> [ b.status, a.start_at, a.end_at, a.created_at ] }
	end
	
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
