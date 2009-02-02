module MatchesHelper

	def default_matches_order
		'status, start_at DESC, end_at DESC, created_at DESC'
	end

	def match_accessible_conditions
		"matches.id <> 999"
	end
	
	def match_status_conditions(status, current = nil)
		status_code = Code.find_by_codeable_type_and_name('match_status', status).code
		conditions_list = [ "matches.status = '#{status_code}'" ]
		if status == 'doing'
			conditions_list += [ "matches.start_at <= '#{time_iso_format(current)}'", "matches.end_at >= '#{time_iso_format(current)}'" ]
		end
		conditions_list.join(' AND ')
	end

	def accessible_matches(matches_set)
		matches = []
		for match in matches_set
			matches << match if match.accessible?
		end
		matches
	end
	
	def user_joined_matches(user, match_actors_conditions, match_conditions, limit = nil, order = nil)
		match_actors = user.match_actors.find(:all, :limit => limit, :order => order, 
													 								:joins => "JOIN matches ON match_actors.match_id = matches.id", 
													 								:conditions => "#{match_actors_conditions} AND #{match_conditions}")
		joined_matches(match_actors)
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
		joined_matches(match_actors)
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
			matches_set = accessible_matches(Match.find(:all))
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
