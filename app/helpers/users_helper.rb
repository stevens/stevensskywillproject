module UsersHelper
	def user_portrait(user)
		user.photos.find(:first, 
										 :conditions => ["photoable_type = 'User' AND 
																		 photoable_id = ?", 
																		 user.id])
	end
	
	def user_first_link(user)
		if user
			if user == @current_user
				url_for(:controller => 'mine', :action => 'overview')
			else
				"#{user_path(user)}/overview"
			end
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