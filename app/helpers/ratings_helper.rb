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
	
	def highlighted_items(items_set)
		min_highlighted_rating = 7
		max_highlighted_rating = 10
		min_ratings_count = 2
		
		items = []
		for item in items_set
			rating = item.rating ? item.rating : 0
			if rating >= min_highlighted_rating && rating <= max_highlighted_rating && item.total_ratings >= min_ratings_count
				items << item
			end
		end
		items
	end

end
