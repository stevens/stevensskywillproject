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
	
	def highlighted_recipes(user, integrality, created_at_from, created_at_to, order)
		recipes = recipes_for(user, integrality, created_at_from, created_at_to, order) 
		highlighted_recipes = []
		for recipe in recipes
			rating = recipe.rating ? recipe.rating : 0
			if rating >= MIN_HILIGHTED_ITEM_RATING && rating <= MAX_HILIGHTED_ITEM_RATING && recipe.total_ratings >= MIN_RATINGS_COUNT
				highlighted_recipes << recipe
			end
		end
		highlighted_recipes
	end
	
	def recipes_for(user, photo_required = recipe_photo_required_condition(user), status = recipe_status_condition(user), privacy = recipe_privacy_condition(user), created_at_from = nil, created_at_to = nil, order = 'created_at DESC')
		if user
			user.recipes.find(:all, :order => order, 
												:conditions => [recipes_conditions(photo_required, status, privacy, created_at_from, created_at_to)])
		else
			Recipe.find(:all, :order => order, 
									:conditions => [recipes_conditions(photo_required, status, privacy, created_at_from, created_at_to)])
		end
	end
	
  def recipes_conditions(photo_required = true, status = '1', privacy = '10', created_at_from = nil, created_at_to = nil)
  	conditions = ["title IS NOT NULL", 
  								"title <> ''", 
  								"description IS NOT NULL", 
  								"description <> ''", 
  								"from_type IS NOT NULL", 
  								"privacy IS NOT NULL"]
  	conditions << "cover_photo_id IS NOT NULL" if photo_required
  	conditions << "status >= #{status}" if status
  	conditions << "privacy <= #{privacy}" if privacy
  	
  	# case integrality
		# when 'photo_required'
		# 	conditions << "cover_photo_id IS NOT NULL"
		# when 'more_required'
		# 	conditions << ["cover_photo_id IS NOT NULL",
		# 					 			 "ingredients IS NOT NULL", 
		# 								 "ingredients <> ''", 
		# 								 "directions IS NOT NULL", 
		# 								 "directions <> ''", 
		# 								 "difficulty IS NOT NULL", 
		# 								 "cook_time IS NOT NULL"]
		# when 'most_required'
		# 	conditions << ["cover_photo_id IS NOT NULL",
		# 					 			 "ingredients IS NOT NULL", 
		# 								 "ingredients <> ''", 
		# 								 "directions IS NOT NULL", 
		# 								 "directions <> ''", 
		# 								 "difficulty IS NOT NULL", 
		# 								 "cook_time IS NOT NULL", 
		# 								 "prep_time IS NOT NULL", 
		# 								 "yield IS NOT NULL", 
		# 								 "yield <> ''"]
		# when 'full_required'
		# 	conditions << ["cover_photo_id IS NOT NULL",
		# 					 			 "ingredients IS NOT NULL", 
		# 								 "ingredients <> ''", 
		# 								 "directions IS NOT NULL", 
		# 								 "directions <> ''", 
		# 								 "difficulty IS NOT NULL", 
		# 								 "cook_time IS NOT NULL", 
		# 								 "prep_time IS NOT NULL", 
		# 								 "yield IS NOT NULL", 
		# 								 "yield <> ''", 
		# 								 "tips IS NOT NULL", 
		# 								 "tips <> ''", 
		# 								 "any_else IS NOT NULL", 
		# 								 "any_else <> ''"]
		# end
		
		conditions << "recipes.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "recipes.created_at <= '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end  
  
  def recipe_status(recipe)
  	if recipe.title && !recipe.title.blank? &&
  		 recipe.description && !recipe.description.blank? &&
  		 recipe.from_type &&
  		 recipe.privacy
  		if recipe.ingredients && !recipe.ingredients.blank? &&
  			 recipe.directions && !recipe.directions.blank? &&
  			 recipe.difficulty && 
  			 recipe.cook_time
				if recipe.prep_time && 
					 recipe.yield && !recipe.yield.blank?
					if recipe.tips && !recipe.tips.blank? &&
						 recipe.any_else && !recipe.any_else.blank?
						status = '4'
					else
						status = '3'
					end
				else
					status = '2'
				end
			else
				status = '1'
			end
		end	
  end
  
  def recipe_photo_required_condition(user)
  	if user && user == @current_user
			false
  	else
  		true
  	end  	
  end
  
  def recipe_status_condition(user)
  	if user && user == @current_user
			nil
  	else
  		'1'
  	end
  end
  
  def recipe_privacy_condition(user)
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
  
  def recipe_for(user, id, photo_required = recipe_photo_required_condition(user), status = recipe_status_condition(user), privacy = recipe_privacy_condition(user))
  	if user
  		user.recipes.find(id, :conditions => [recipes_conditions(photo_required, status, privacy)])
  	else
  		Recipe.find(id, :conditions => [recipes_conditions(photo_required, status, privacy)])
  	end
  	rescue ActiveRecord::RecordNotFound
  		nil
  end

end
