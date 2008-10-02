module UsersHelper
	def user_portrait(user)
		user.photos.find(:first, 
										 :conditions => ["photoable_type = 'User' AND 
																		 photoable_id = ?", 
																		 user.id])
	end
end