module ReviewsHelper

	def filtered_reviews(user = nil, reviewable_type = nil, filter = nil)
  	if reviewable_type
  		review_conditions = review_conditions(reviewable_type)	
  	end
  	
  	if reviewable_type == 'Recipe'
	 		reviewable_conditions_1 = recipe_conditions(recipe_photo_required_cond, recipe_status_cond, recipe_privacy_cond, recipe_is_draft_cond)
	 	end
	 	
 		if user
 			reviewable_conditions_2 = reviewable_conditions_1 + " AND #{controller_name(reviewable_type)}.user_id = #{user.id}"
 		else
 			reviewable_conditions_2 = reviewable_conditions_1
 		end

 		by_reviews_set = reviews_for(user, reviewable_type, review_conditions, reviewable_conditions_1)
 		to_reviews_set = reviews_for(nil, reviewable_type, review_conditions, reviewable_conditions_2)
 		
 		case filter
 		when 'by'
 			by_reviews_set
 		when 'to'
 			to_reviews_set - by_reviews_set
 		else
 			by_reviews_set | to_reviews_set
 		end
	end

	def reviews_for(user = nil, reviewable_type = nil, review_conditions = review_conditions(reviewable_type), reviewable_conditions = nil, limit = nil, order = 'created_at DESC')
		conditions = []
		conditions << review_conditions if review_conditions
		if reviewable_type && reviewable_conditions
			join_table_name = controller_name(reviewable_type)
			joins = "JOIN #{join_table_name} ON reviews.reviewable_id = #{join_table_name}.id"
			conditions << reviewable_conditions
		end
		if user
			user.reviews.find(:all, :limit => limit, :order => order, :joins => joins, 
												:conditions => conditions.join(" AND "))
		else
			Review.find(:all, :limit => limit, :order => order, :joins => joins, 
									:conditions => conditions.join(" AND "))
		end
	end
  
  def review_conditions(reviewable_type = nil, reviewable_id = nil, created_at_from = nil, created_at_to = nil)
  	conditions = ["reviews.review IS NOT NULL", 
  								"reviews.review <> ''"]
  	conditions << "reviews.reviewable_type = '#{reviewable_type}'" if reviewable_type
  	conditions << "reviews.reviewable_id = #{reviewable_id}" if reviewable_id
		conditions << "reviews.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "reviews.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")
  end
  
  def review_duplicate?(review)
  	conditions = ["reviews.user_id = '#{review.user_id}'", 
  								"reviews.reviewable_type = '#{review.reviewable_type}'", 
  								"reviews.reviewable_id = '#{review.reviewable_id}'", 
  								"reviews.review = '#{review.review}'", 
  								"reviews.created_at > '#{time_iso_format(Time.now - 30.seconds)}'"]
		Review.find(:first, :conditions => conditions.join(" AND ")) ? true : false
  end

end
