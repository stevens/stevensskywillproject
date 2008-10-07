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
	
  def recipe_for(user, id, recipe_conditions = recipe_conditions({:photo_required => recipe_photo_required_cond(user), :status => recipe_status_cond(user), :privacy => recipe_privacy_cond(user), :is_draft => recipe_is_draft_cond(user)}))
  	if user
  		user.recipes.find(id, :conditions => [recipe_conditions])
  	else
  		Recipe.find(id, :conditions => [recipe_conditions])
  	end
  	rescue ActiveRecord::RecordNotFound
  		nil
  end
  
	def recipes_for(user, recipe_conditions = recipe_conditions({:photo_required => recipe_photo_required_cond(user), :status => recipe_status_cond(user), :privacy => recipe_privacy_cond(user), :is_draft => recipe_is_draft_cond(user)}), order = 'published_at DESC, created_at DESC')
		if user
			user.recipes.find(:all, :order => order, 
												:conditions => [recipe_conditions])
		else
			Recipe.find(:all, :order => order, 
									:conditions => [recipe_conditions])
		end
	end
  
  def recipe_conditions(conds = {:photo_required => true, :status => '1', :privacy => '10', :is_draft => '0', :created_at_from => nil, :created_at_to => nil})
  	conditions = ["recipes.title IS NOT NULL", 
  								"recipes.title <> ''", 
  								"recipes.description IS NOT NULL", 
  								"recipes.description <> ''", 
  								"recipes.from_type IS NOT NULL", 
  								"recipes.privacy IS NOT NULL"]
  	conditions << "recipes.cover_photo_id IS NOT NULL" if conds[:photo_required]
  	conditions << "recipes.status >= #{conds[:status]}" if conds[:status]
  	conditions << "recipes.privacy <= #{conds[:privacy]}" if conds[:privacy]
  	conditions << "recipes.is_draft = #{conds[:is_draft]}" if conds[:is_draft]
		conditions << "recipes.created_at >= '#{time_iso_format(conds[:created_at_from])}'" if conds[:created_at_from]
		conditions << "recipes.created_at <= '#{time_iso_format(conds[:created_at_to])}'" if conds[:created_at_to]
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
  
  def recipe_is_draft_cond(user)
  	if user && user == @current_user
			nil
  	else
  		'0'
  	end
  end

end
