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
	
	def highlighted_recipes
		Recipe.find(:all, :conditions => ["cover_photo_id IS NOT NULL"])
	end
  
  def latest_recipes(user, order, base_time, only_has_photo, only_full_info)
		if user
			if only_full_info
				user.recipes.find(:all, :order => order, 
													:conditions => ["title IS NOT NULL AND 
																					title <> '' AND 
																					description IS NOT NULL AND 
																					description <> '' AND 
																					ingredients IS NOT NULL AND 
																					# ingredients <> '' AND 
																					directions IS NOT NULL AND 
																					# directions <> '' AND 
																					cover_photo_id IS NOT NULL AND 
																					# difficulty IS NOT NULL AND 
																					# prep_time > 0 AND 
																					# cook_time > 0 AND 
																					yield IS NOT NULL AND 
																					# yield <> '' AND 
																					created_at >= ?",  
																					base_time])
			elsif only_has_photo
				user.recipes.find(:all, :order => order, 
													:conditions => ["title IS NOT NULL AND 
																					title <> '' AND 
																					description IS NOT NULL AND 
																					description <> '' AND 
																					cover_photo_id IS NOT NULL AND 
																					created_at >= ?",  
																					base_time])
			
			else
				user.recipes.find(:all, :order => order, 
													:conditions => ["title IS NOT NULL AND 
																					title <> '' AND 
																					description IS NOT NULL AND 
																					description <> ''"])
			end
		else
			if only_full_info
				Recipe.find(:all, :order => order, 
										:conditions => ["title IS NOT NULL AND 
																		title <> '' AND 
																		description IS NOT NULL AND 
																		description <> '' AND 
																		ingredients IS NOT NULL AND 
																		# ingredients <> '' AND 
																		directions IS NOT NULL AND 
																		# directions <> '' AND 
																		cover_photo_id IS NOT NULL AND 
																		# difficulty IS NOT NULL AND 
																		# prep_time > 0 AND 
																		# cook_time > 0 AND 
																		yield IS NOT NULL AND 
																		# yield <> '' AND 
																		created_at >= ?",  
																		base_time])
			elsif only_has_photo
				Recipe.find(:all, :order => order, 
										:conditions => ["title IS NOT NULL AND 
																		title <> '' AND 
																		description IS NOT NULL AND 
																		description <> '' AND 
																		cover_photo_id IS NOT NULL AND 
																		created_at >= ?",  
																		base_time])
			
			else
				Recipe.find(:all, :order => order, 
										:conditions => ["title IS NOT NULL AND 
																		title <> '' AND 
																		description IS NOT NULL AND 
																		description <> ''"])
			end
		end
  end

end
