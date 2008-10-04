module ReviewsHelper

	def reviews_for(user, reviewable_type, reviewable_id, created_at_from = nil, created_at_to = nil, order = 'created_at DESC')
		if user
			if reviewable_type || reviewable_id || created_at_from || created_at_to
				user.reviews.find(:all, :order => order, 
													:conditions => [reviews_conditions(reviewable_type, reviewable_id, created_at_from, created_at_to)])
			else
				user.reviews.find(:all, :order => order)
			end			
		else
			Review.find(:all, :order => order, 
									:conditions => [reviews_conditions(reviewable_type, reviewable_id, created_at_from, created_at_to)])
		end
	end
  
  def reviews_conditions(reviewable_type, reviewable_id, created_at_from = nil, created_at_to = nil)
  	conditions = ["review IS NOT NULL", 
  								"review <> ''"]
  	conditions << "reviewable_type = '#{reviewable_type}'" if reviewable_type
  	conditions << "reviewable_id = #{reviewable_id}" if reviewable_id
		conditions << "reviews.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "reviews.created_at <= '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end

end
