module UsersHelper
	
	def users_for(conditions = user_conditions, limit = nil, order = 'activated_at DESC, created_at DESC')
		User.find(:all, :limit => limit, :order => order, 
							:conditions => user_conditions)
	end
  
  def user_conditions(activated = true, created_at_from = nil, created_at_to = nil)
  	conditions = ["users.login IS NOT NULL", 
  								"users.login <> ''", 
  								"users.email IS NOT NULL", 
  								"users.email <> ''"]
  	conditions << "users.activated_at IS NOT NULL" if activated
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
	
	def user_first_link(user)
		if user
			"#{user_path(user)}/profile"
		end
	end
	
	def user_username(user)
		if @current_user && user == @current_user
			'我'
		else
			# 'TA'
			user.login
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
end