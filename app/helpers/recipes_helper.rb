module RecipesHelper

	def recipe_tags_cloud(user)
		if user
			user.recipes.tag_counts
		else
			Recipe.tag_counts
		end
	end
	
	def search_result_recipes(user, keywords, order)
		if keywords && keywords != []
			conditions = "title LIKE '%#{keywords[0]}%'"
			tags = keywords[0]
			2.upto(keywords.size) do |i|
				conditions += " AND title LIKE '%#{keywords[i-1]}%'"
				tags += " #{keywords[i-1]}"
			end
		else
			conditions = nil
			tags = nil
		end
		if user
			conditions_result_recipes = user.recipes.find(:all, :order => order, :conditions => conditions)
			tags_result_recipes = user.recipes.find_tagged_with(tags, :match_all => true)
		else
			conditions_result_recipes = Recipe.find(:all, :order => order, :conditions => conditions)
			tags_result_recipes = Recipe.find_tagged_with(tags, :match_all => true)
		end
		conditions_result_recipes | tags_result_recipes
	end
	
	def highlighted_recipes(user, only_has_photo, only_full_info, created_at_from, created_at_to, order)
		if user
			recipes = user.recipes.find_all_by_rating(MIN_HILIGHTED_ITEM_RATING..MAX_HILIGHTED_ITEM_RATING, 
																								:order => "recipes.#{order}", 
																								:conditions => ["#{recipes_conditions(only_has_photo, only_full_info, created_at_from, created_at_to)}"])
		else
			recipes = Recipe.find_all_by_rating(MIN_HILIGHTED_ITEM_RATING..MAX_HILIGHTED_ITEM_RATING, 
																					:order => "recipes.#{order}", 
																					:conditions => ["#{recipes_conditions(only_has_photo, only_full_info, created_at_from, created_at_to)}"])
		end
		highlighted_recipes = []
		for recipe in recipes
			if recipe.rating >= MIN_HILIGHTED_ITEM_RATING && recipe.rating <= MAX_HILIGHTED_ITEM_RATING && recipe.total_ratings >= MIN_RATINGS_COUNT
				highlighted_recipes << recipe
			end
		end
		highlighted_recipes
	end
	
	def recipes_for(user, only_has_photo, only_full_info, created_at_from, created_at_to, order)
		if user
			user.recipes.find(:all, :order => order, 
												:conditions => ["#{recipes_conditions(only_has_photo, only_full_info, created_at_from, created_at_to)}"])
		else
			Recipe.find(:all, :order => order, 
									:conditions => ["#{recipes_conditions(only_has_photo, only_full_info, created_at_from, created_at_to)}"])
		end
	end
	
  def recipes_conditions(only_has_photo, only_full_info, created_at_from, created_at_to)
  	conditions = ["title IS NOT NULL", 
  								"title <> ''", 
  								"description IS NOT NULL", 
  								"description <> ''", 
  								"from_type IS NOT NULL", 
  								"privacy IS NOT NULL"]
		conditions << "cover_photo_id IS NOT NULL" if only_has_photo
		if only_full_info
			conditions << ["ingredients IS NOT NULL", 
										 "ingredients <> ''", 
										 "directions IS NOT NULL", 
										 "directions <> ''", 
										 "cover_photo_id IS NOT NULL", 
										 "difficulty IS NOT NULL", 
										 "prep_time IS NOT NULL", 
										 "cook_time IS NOT NULL", 
										 "yield IS NOT NULL", 
										 "yield <> ''"]
		end
		conditions << "recipes.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "recipes.created_at <= '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end  
  

end
