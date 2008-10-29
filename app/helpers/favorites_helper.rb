module FavoritesHelper

	def favorite_statuses(favorable_type)
		conditions = ["codes.codeable_type = 'favorite_status'"]
		conditions << "codes.code LIKE '#{code_for(favorable_type)}__'"
		statuses_set = Code.find(:all, :order => 'code', 
														 :conditions => conditions.join(' AND '))
		statuses_set.group_by { |status| (status.code[1..1]) }.sort { |a, b| a <=> b }
	end
	
	def favorites_for(user = nil, favorable_type = nil, favorite_conditions = favorite_conditions(favorable_type), favorable_conditions = nil, limit = nil, order = 'created_at DESC')
		conditions = []
		conditions << favorite_conditions if favorite_conditions
		if favorable_type && favorable_conditions
			join_table_name = controller_name(favorable_type)
			joins = "JOIN #{join_table_name} ON favorites.favorable_id = #{join_table_name}.id"
			conditions << favorable_conditions
		end
		if user
			user.favorites.find(:all, :limit => limit, :order => order, :joins => joins, 
													:conditions => conditions.join(" AND "))
		else
			Favorite.find(:all, :limit => limit, :order => order, :joins => joins, 
										:conditions => conditions.join(" AND "))
		end
	end
	
  def favorite_conditions(favorable_type = nil, favorable_id = nil, status = nil, created_at_from = nil, created_at_to = nil)
  	conditions = ["favorites.status IS NOT NULL", 
  								"favorites.status <> ''"]
  	conditions << "favorites.favorable_type = '#{favorable_type}'" if favorable_type
  	conditions << "favorites.favorable_id = #{favorable_id}" if favorable_id
  	conditions << "favorites.status LIKE '%#{status}%'" if status
		conditions << "favorites.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "favorites.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end

end
