module RecipesHelper
  
	def filtered_recipes(user = nil, filter = nil, limit = nil, order = 'published_at DESC, created_at DESC')
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
 		else
 			is_draft_cond = recipe_is_draft_cond(user)
 		end
 		recipe_conditions = []
 		recipe_conditions << recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), is_draft_cond)
 		recipe_conditions << "recipes.from_type = #{from_type_cond}" if from_type_cond
 		recipes_for(user, recipe_conditions.join(' AND '), limit, order)
	end
	
	def recipes_for(user = nil, recipe_conditions = recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), limit = nil, order = 'published_at DESC, created_at DESC')
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
