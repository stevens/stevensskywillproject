module ReviewsHelper

	def reviews_for(user, reviewable_type, reviewable_id, order)
		if user
			if reviewable_type && reviewable_id
				user.reviews.find(:all, :order => order, 
													:conditions => ["reviewable_type = ? AND 
																			 		reviewable_id = ?", 
																			 		reviewable_type, 
																			 		reviewable_id])
			else
				user.reviews.find(:all, :order => order)
			end
		else
			if reviewable_type && reviewable_id
				Review.find(:all, :order => order, 
										:conditions => ["reviewable_type = ? AND 
																		reviewable_id = ?", 
																		reviewable_type, 
																		reviewable_id])
			else
				Review.find(:all, :order => order)
			end
		end
	end
	
  def latest_reviews(user, reviewable_type, reviewable_id, order, base_time)
		if user
			if reviewable_type && reviewable_id
				user.reviews.find(:all, :order => order, 
													:conditions => ["reviewable_type = ? AND 
																			 		reviewable_id = ? AND 
																			 		created_at >= ?", 
																			 		reviewable_type, 
																			 		reviewable_id, 
																			 		base_time])
			elsif reviewable_type
				user.reviews.find(:all, :order => order, 
													:conditions => ["reviewable_type = ? AND 
																			 		created_at >= ?", 
																			 		reviewable_type, 
																			 		base_time])
			else
				user.reviews.find(:all, :order => order, 
													:conditions => ["created_at >= ?", 
																					base_time])
			end
		else
			if reviewable_type && reviewable_id
				Review.find(:all, :order => order, 
										:conditions => ["reviewable_type = ? AND 
																		reviewable_id = ? AND 
																		created_at >= ?", 
																		reviewable_type, 
																		reviewable_id, 
																		base_time])
			elsif reviewable_type
				Review.find(:all, :order => order, 
										:conditions => ["reviewable_type = ? AND 
																		created_at >= ?", 
																		reviewable_type, 
																		base_time])
			else
				Review.find(:all, :order => order, 
										:conditions => ["created_at >= ?", 
																		base_time])
			end
		end
  end

end
