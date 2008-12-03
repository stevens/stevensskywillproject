module FavoritesHelper

	def favorite_statuses(favorable_type)
		# conditions = ["codes.codeable_type = 'favorite_status'"]
		# conditions << "codes.code LIKE '#{code_for(favorable_type)}__'"
		# statuses_set = Code.find(:all, :order => 'code', 
		# 												 :conditions => conditions.join(' AND '))
		statuses_set = Code.find(:all, :order => 'code', 
														 :conditions => { :codeable_type => "#{favorable_type.downcase}_favorite_status" })
		statuses_set.group_by { |status| (status.code[1..1]) }.sort { |a, b| a <=> b }
	end
	
	def filtered_favorites(user = nil, favorable_type = nil, filter = nil, limit = nil, order = 'created_at DESC')
 		if filter
 			favorite_status_cond = Code.find(:first, 
 																			 :conditions => { :codeable_type => "#{favorable_type.downcase}_favorite_status", 
 																			 									:name => filter }).code
 		end
 		favorite_conditions = favorite_conditions(favorable_type, nil, favorite_status_cond)

  	case favorable_type
  	when 'Recipe'
	 		favorable_conditions = recipe_conditions(recipe_photo_required_cond, recipe_status_cond, recipe_privacy_cond, recipe_is_draft_cond)
	 	end
 		
 		favorites_for(user, favorable_type, favorite_conditions, favorable_conditions, limit, order)
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
  
  def classified_favorite_statuses(favorites)
		statuses_set = []
		for favorite in favorites
			statuses_set += favorite.status.split(' ')
		end
		statuses_set = statuses_set.group_by { |status| (status) }.sort { |a, b| a <=> b }
		statuses_set.group_by { |statuses| (statuses[0][1..1]) }.sort { |a, b| a <=> b }
  end

end
