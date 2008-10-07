module RatingsHelper
	
	def user_rating(user, rateable)
		user_rating = rateable.ratings.find_by_user_id(user)
	end
	
	def user_rating_value(user, rateable)
		user_rating = user_rating(user, rateable)
		user_rating ? user_rating.rating : 0
	end
	
	def average_rating_value(rateable)
		rateable.ratings.size > 0 ? f(rateable.ratings.average('rating')) : 0
	end

end
