module RatingsHelper

	def ratings_count(rateable)
		Rating.count(:conditions => {:rateable_type => type_for(rateable), :rateable_id => rateable.id})
	end
	
	def user_rating(user, rateable)
		if user
			user_rating = user.ratings.find(:first, :conditions => {:rateable_type => type_for(rateable), :rateable_id => rateable.id})
			user_rating ? user_rating.rating : 0
		end
	end
	
	def total_rating(rateable)
		ratings_count = ratings_count(rateable)
		if ratings_count > 0
			Rating.average('rating', :conditions => {:rateable_type => type_for(rateable), :rateable_id => rateable.id})
		else
			0
		end
	end

end
