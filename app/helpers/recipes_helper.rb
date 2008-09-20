module RecipesHelper

	def recipe_tags_cloud(user)
		if user
			user.recipes.tag_counts
		else
			Recipe.tag_counts
		end
	end
	
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
	
	def recipes_for(user, integrality, created_at_from, created_at_to, order)
		if user
			user.recipes.find(:all, :order => order, 
												:conditions => [recipes_conditions(integrality, created_at_from, created_at_to)])
		else
			Recipe.find(:all, :order => order, 
									:conditions => [recipes_conditions(integrality, created_at_from, created_at_to)])
		end
	end
	
  def recipes_conditions(integrality, created_at_from, created_at_to)
  	conditions = ["title IS NOT NULL", 
  								"title <> ''", 
  								"description IS NOT NULL", 
  								"description <> ''", 
  								"from_type IS NOT NULL", 
  								"privacy IS NOT NULL"]
  	case integrality
		when 'photo_required'
			conditions << "cover_photo_id IS NOT NULL"
		when 'more_required'
			conditions << ["cover_photo_id IS NOT NULL",
							 			 "ingredients IS NOT NULL", 
										 "ingredients <> ''", 
										 "directions IS NOT NULL", 
										 "directions <> ''", 
										 "difficulty IS NOT NULL", 
										 "cook_time IS NOT NULL"]
		when 'most_required'
			conditions << ["cover_photo_id IS NOT NULL",
							 			 "ingredients IS NOT NULL", 
										 "ingredients <> ''", 
										 "directions IS NOT NULL", 
										 "directions <> ''", 
										 "difficulty IS NOT NULL", 
										 "cook_time IS NOT NULL", 
										 "prep_time IS NOT NULL", 
										 "yield IS NOT NULL", 
										 "yield <> ''"]
		when 'full_required'
			conditions << ["cover_photo_id IS NOT NULL",
							 			 "ingredients IS NOT NULL", 
										 "ingredients <> ''", 
										 "directions IS NOT NULL", 
										 "directions <> ''", 
										 "difficulty IS NOT NULL", 
										 "cook_time IS NOT NULL", 
										 "prep_time IS NOT NULL", 
										 "yield IS NOT NULL", 
										 "yield <> ''", 
										 "tips IS NOT NULL", 
										 "tips <> ''", 
										 "any_else IS NOT NULL", 
										 "any_else <> ''"]
		end
		conditions << "recipes.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "recipes.created_at <= '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end  
  

end
