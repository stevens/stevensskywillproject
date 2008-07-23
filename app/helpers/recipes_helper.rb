module RecipesHelper
  
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
