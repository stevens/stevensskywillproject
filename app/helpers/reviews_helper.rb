module ReviewsHelper

	def reviews_for(reviewable_type, reviewable_id, user)
		if user
			user.reviews.find(:all, 
											 :conditions => { :reviewable_type => reviewable_type, :reviewable_id => reviewable_id},
											 :order => "updated_at DESC")
		else
			Review.find(:all, 
								 :conditions => { :reviewable_type => reviewable_type, :reviewable_id => reviewable_id},
								 :order => "updated_at DESC")
		end
	end

end
