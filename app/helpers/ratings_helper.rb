module RatingsHelper
	
	def user_rating(user, rateable)
		user_rating = rateable.ratings.find_by_user_id(user)
	end
	
	def user_rating_value(user, rateable)
		user_rating = user_rating(user, rateable)
		if user_rating
			r = user_rating.rating / 10.0
			r == r.round ? r.round : r
		else
			0
		end
	end
	
	def average_rating_value(rateable)
		if rateable.ratings.size > 0
			r = rateable.ratings.average('rating') / 10.0
			r == r.round ? r.round : f(r, 2)
		else
			0
		end
	end
	
	def highest_rated_items(items_set)
		min_rating = 8.5
		max_rating = 10
		min_ratings_count = 4
		
		items = []
		for item in items_set
			if item.rating
				rating = item.rating / 10.0
			else
				rating = 0
			end
			if rating >= min_rating && rating <= max_rating && item.total_ratings >= min_ratings_count
				items << item
			end
		end
		items.sort {|a,b| [b.rating, b.total_ratings, b.favorites.size, b.reviews.size] <=> [a.rating, a.total_ratings, a.favorites.size, a.reviews.size]}
	end

end
