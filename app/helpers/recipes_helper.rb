module RecipesHelper
	
	def search_result_recipes(user, keywords, order, other_conditions)
		if keywords && keywords != []
			conditions = "title LIKE '%#{keywords[0]}%'"
			tags = keywords[0]
			2.upto(keywords.size) do |i|
				conditions += " AND title LIKE '%#{keywords[i-1]}%'"
				tags += " #{keywords[i-1]}"
			end
			conditions += "AND #{other_conditions}"
		else
			conditions = nil
			tags = nil
		end
		if user
			conditions_result_recipes = user.recipes.find(:all, :order => order, :conditions => conditions)
			tags_result_recipes = user.recipes.find_tagged_with(tags, :match_all => true, :conditions => other_conditions)
		else
			conditions_result_recipes = Recipe.find(:all, :order => order, :conditions => conditions)
			tags_result_recipes = Recipe.find_tagged_with(tags, :match_all => true, :conditions => other_conditions)
		end
		conditions_result_recipes | tags_result_recipes
	end
  
	def recipes_for(user = nil, recipe_conditions = recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), limit = nil, order = 'published_at DESC, created_at DESC')
		if user
			user.recipes.find(:all, :limit => limit, :order => order, 
												:conditions => [recipe_conditions])
		else
			Recipe.find(:all, :limit => limit, :order => order, 
									:conditions => [recipe_conditions])
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
		conditions << "recipes.created_at <= '#{time_iso_format(created_at_to)}'" if created_at_to
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
