module RecipesHelper
  
	def filtered_recipes(user = nil, filter = nil, limit = nil, order = 'created_at DESC, published_at DESC')
 		case filter
 		when 'published'
 			is_draft_cond = '0'
 		when 'draft'
 			is_draft_cond = '1'
 		when 'original'
 			is_draft_cond = recipe_is_draft_cond(user)
 			from_type_cond = '1'
 		when 'repaste'
 			is_draft_cond = recipe_is_draft_cond(user)
 			from_type_cond = '2'
    when 'choice'
      is_draft_cond = recipe_is_draft_cond(user)
      role_cond = '11'
 		else
 			is_draft_cond = recipe_is_draft_cond(user)
 		end
 		recipe_conditions = []
 		recipe_conditions << recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), is_draft_cond)
 		recipe_conditions << "recipes.from_type = #{from_type_cond}" if from_type_cond
    recipe_conditions << "recipes.roles LIKE '%#{role_cond}%'" if role_cond
 		recipes_for(user, recipe_conditions.join(' AND '), limit, order)
	end
	
	def roles_recipes(user = nil, role_condition = nil, limit = nil, order = 'RAND()')
 		recipe_conditions = []
 		recipe_conditions << recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user))
 		recipe_conditions << "recipes.roles LIKE '%#{role_condition}%'" if role_condition
 		recipes_for(user, recipe_conditions.join(' AND '), limit, order)	
	end
        
  def love_recipes(user = nil, role_condition = nil, published_at_from = '2009-08-01 00:00:00', published_at_to = '2010-07-31 23:59:59', limit = nil, order = 'RAND()')
    recipe_conditions = []
    #recipe_conditions << recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user))
    recipe_conditions << "recipes.roles LIKE '%#{role_condition}%'" if role_condition
    recipe_conditions << "recipes.published_at >= '#{published_at_from}'" if published_at_from
    recipe_conditions << "recipes.published_at <= '#{published_at_to}'" if published_at_to
    recipes_for(user, recipe_conditions.join(' AND '), limit, order)
  end

  def love_recipe_stats_set(user = nil, current = Time.now, start_at = '2009-08-01 00:00:00', end_at = '2010-07-31 23:59:59')
    stats = []
    if current >= start_at.to_time && current <= end_at.to_time
      phase_start = start_at.to_time.at_beginning_of_month
      awards = [ [User.find_by_id(1163), User.find_by_id(272)] ]
      1.upto(12) do |i|
        phase_end = phase_start.at_end_of_month          
        stats << [ phase_start.strftime("%Y-%m"), love_recipes(user, '21', phase_start.strftime("%Y-%m-%d %H:%M:%S"), phase_end.strftime("%Y-%m-%d %H:%M:%S")).size, awards[i-1] ]
        if phase_end.strftime("%Y-%m") == current.strftime("%Y-%m")
          break
        else
          phase_start = phase_start + 1.month
        end
      end
    end
    stats
  end
	
	def recipes_for(user = nil, recipe_conditions = recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), limit = nil, order = 'created_at DESC, published_at DESC')
		if user
			user.recipes.find(:all, :limit => limit, :order => order, 
												:conditions => recipe_conditions)
		else
			Recipe.find(:all, :limit => limit, :order => order, 
									:conditions => recipe_conditions)
		end
	end
	
	def recipe_accessible?(recipe)
		if is_draft_cond = recipe_is_draft_cond(recipe.user)
			if recipe.privacy.to_i <= recipe_privacy_cond(recipe.user).to_i && recipe.is_draft == is_draft_cond
				true
			end
		else
			if recipe.privacy.to_i <= recipe_privacy_cond(recipe.user).to_i
				true
			end
		end
	end
  
  def recipe_conditions(photo_required = true, status = '1', privacy = '10', is_draft = '0', created_at_from = nil, created_at_to = nil)
  	conditions = ["recipes.title IS NOT NULL", 
  								"recipes.title <> ''", 
  								"recipes.description IS NOT NULL", 
  								"recipes.description <> ''", 
  								"recipes.from_type IS NOT NULL", 
  								"recipes.privacy IS NOT NULL"]
  	conditions << "recipes.cover_photo_id IS NOT NULL" if photo_required
  	conditions << "recipes.status >= #{status}" if status
  	conditions << "recipes.privacy <= #{privacy}" if privacy
  	conditions << "recipes.is_draft = #{is_draft}" if is_draft
		conditions << "recipes.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "recipes.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end  
  
  def recipe_photo_required_cond(user = nil)
  	if user && user == @current_user
			false
  	else
  		true
  	end  	
  end
  
  def recipe_status_cond(user = nil)
  	if user && user == @current_user
			nil
  	else
  		'1'
  	end
  end
  
  def recipe_privacy_cond(user = nil)
  	if @current_user
  		if user && user == @current_user
  			'90'	
  		else
  			'11'
  		end
  	else
  		'10'
  	end
  end
  
  def recipe_is_draft_cond(user = nil)
  	if user && user == @current_user
			nil
  	else
  		'0'
  	end
  end

end
