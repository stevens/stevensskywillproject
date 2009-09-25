module UsersHelper
	
	def users_for(conditions = user_conditions, limit = nil, order = 'activated_at DESC, created_at DESC')
		User.find(:all, :limit => limit, :order => order, 
							:conditions => conditions)
	end
        
  def love_users(user = nil)
#    User.find_by_sql("select users.* from users,recipes where users.id = recipes.user_id and recipes.roles LIKE '%21%'  GROUP BY recipes.user_id  ORDER BY RAND() ")
    User.find_by_sql("SELECT users.id, users.login, COUNT(recipes.id) AS love_recipes_count
                      FROM recipes
                      INNER JOIN users
                      ON recipes.user_id = users.id
                      WHERE recipes.published_at >=  '2009-08-01 00:00:00'
                      AND recipes.published_at <=  '2010-07-31 23:59:59'
                      AND recipes.roles LIKE  '%21%'
                      GROUP BY recipes.user_id
                      ORDER BY RAND()")
  end
  
  def user_conditions(role = nil, activated = true, created_at_from = nil, created_at_to = nil)
  	conditions = ["users.login IS NOT NULL", 
  								"users.login <> ''", 
  								"users.email IS NOT NULL", 
  								"users.email <> ''"]
  	conditions << "users.activated_at IS NOT NULL" if activated
  	conditions << "users.roles LIKE '%#{role}%'" if role
		conditions << "users.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "users.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end
	
	def user_portrait(user)
		user.photos.find(:first, 
										 :conditions => ["photoable_type = 'User' AND 
																		 photoable_id = ?", 
																		 user.id])
	end
	
	def user_first_link(user, only_path = true)
		if user
			if only_path
				"#{user_path(user)}/profile"
			else
				"#{user_url(user)}/profile"
			end
		end
	end
	
	def user_username(user, show_username = true, show_myname = false)
		if @current_user && user == @current_user
			if show_myname
				user.login
			else
				'我'
			end
		else
			if show_username
				user.login
			else
				'TA'
			end
		end	
	end
	
	def username_prefix(user)
		if user
			"#{user_username(user)}的"
		else
			nil
		end
	end
	
	def user_html_id(user = nil)
		if user
			"user_#{user.id}"
		else
			"all_users"
		end
	end
	
	def user_role_code(role_name)
		codes_for(code_conditions('user_role', nil, nil, role_name), 1)[0].code
	end
end