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
      awards = [ [1163, 1186, 272], [1606, 1399, 25], [1798, 1606, 1579], [1787, 1677, 399], [1798, 253, 1581], [1787, 1822, 1218], [2377, 1618, 2365] ]
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

  # 获取PK赛的名称
  def pk_game_title(game)
    case game
    when '1'
      '中西点心对对碰'
    end
  end

  # 获取PK赛某一轮的对阵和投票结果
  def pk_game_groups(game, round)
    case game
    when '1'
      case round
      when '1'
        [ ['A', [890, 860], [21, 5]], ['B', [900, 921], [14, 12]], ['C', [980, 840], [7, 19]], ['D', [953, 868], [17, 9]],
          ['E', [931, 884], [20, 6]], ['F', [994, 889], [17, 9]], ['G', [1002, 879], [16, 10]], ['H', [996, 898], [12, 14]],
          ['I', [878, 828], [4, 22]], ['J', [893, 877], [14, 12]], ['K', [895, 810], [12, 14]], ['L', [817, 812], [5, 21]],
          ['M', [998, 803], [6, 20]], ['N', [954, 814], [11, 15]], ['O', [970, 977], [11, 15]], ['P', [786, 813], [12, 14]] ]
      when '2'
        [ ['A', [953, 803], [10, 15]], ['B', [890, 812], [15, 10]], ['C', [931, 828], [13, 12]], ['D', [900, 977], [15, 10]],
          ['E', [994, 810], [11, 14]], ['F', [1002, 840], [13, 12]], ['G', [893, 814], [12, 13]], ['H', [898, 813], [15, 10]] ]
      when '3'
        [ ['A', [931, 898], [21, 6]], ['B', [890, 810], [17, 10]], ['C', [1002, 814], [13, 14]], ['D', [900, 803], [7, 20]] ]
      when '4'
        [ ['A', [890, 814], [14, 13]], ['B', [931, 803], [20, 7]] ]
      when '5'
        [ ['A', [890, 931], [9, 22]] ]
      end
    end
  end

end
