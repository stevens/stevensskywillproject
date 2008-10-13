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
	
	def highest_rated_items(items_set)
		min_rating = 7
		max_rating = 10
		min_ratings_count = 2
		
		items = []
		for item in items_set
			rating = item.rating ? item.rating : 0
			if rating >= min_rating && rating <= max_rating && item.total_ratings >= min_ratings_count
				items << item
			end
		end
		items.sort! {|a,b| b.rating <=> a.rating}
		items.sort! {|a,b| b.total_ratings <=> a.total_ratings}
	end

end
