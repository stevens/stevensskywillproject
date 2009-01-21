module ReviewsHelper

	def by_reviews_set(user, reviewable_type = nil)
		by_reviews_set = []
		if reviewable_type.blank?
			reviews_set = user.reviews.find(:all)
		else
			reviews_set = user.reviews.find(:all, :conditions => { :reviewable_type => reviewable_type })
		end
		for review in reviews_set
			by_reviews_set << review if review.reviewable.accessible?(@current_user)
		end
		by_reviews_set
	end
	
	def to_reviews_set(user, reviewable_type = nil)
		to_reviews_set = []
		if reviewable_type.blank?
			for reviewable_type in %w[ Recipe ]
				reviewables_set = model_for(reviewable_type).find(:all, :conditions => { :user_id => user.id })
				for reviewable in reviewables_set
					to_reviews_set += reviewable.reviews.find(:all, :conditions => "reviews.user_id <> '#{user.id}'") if reviewable.accessible?(@current_user)
				end				
			end
		else
			reviewables_set = model_for(reviewable_type).find(:all, :conditions => { :user_id => user.id })
			for reviewable in reviewables_set
				to_reviews_set += reviewable.reviews.find(:all, :conditions => "reviews.user_id <> '#{user.id}'") if reviewable.accessible?(@current_user)
			end
		end
		to_reviews_set
	end
	
	def filtered_reviews_set(user, reviewable_type = nil, filter = nil)
		case filter
		when 'by'
			reviews_set = by_reviews_set(user, reviewable_type)
		when 'to'
			reviews_set = to_reviews_set(user, reviewable_type)
		else
			reviews_set = by_reviews_set(user, reviewable_type) | to_reviews_set(user, reviewable_type)
		end
		reviews_set.sort { |a, b| b.created_at <=> a.created_at }
	end
	
	def reviewable_type_reviews(reviewable_type)
		reviewable_type_reviews = []
		reviews_set = Review.find(:all, :conditions => { :reviewable_type => reviewable_type })
		for review in reviews_set
			reviewable_type_reviews << review if review.reviewable.accessible?(@current_user)
		end
		reviewable_type_reviews
	end

	def filtered_reviews(user = nil, reviewable_type = nil, filter = nil, limit = nil, order = 'created_at DESC')
		review_conditions = review_conditions(reviewable_type)
		
  	case reviewable_type
  	when 'Recipe'
	 		reviewable_conditions_1 = recipe_conditions(recipe_photo_required_cond, recipe_status_cond, recipe_privacy_cond, recipe_is_draft_cond)
	 	end
	 	
	 	reviewable_conditions_2 = []
 		reviewable_conditions_2 << reviewable_conditions_1
		reviewable_conditions_2 << "#{controller_name(reviewable_type)}.user_id = #{user.id}" if user

 		by_reviews_set = reviews_for(user, reviewable_type, review_conditions, reviewable_conditions_1)
 		to_reviews_set = reviews_for(nil, reviewable_type, review_conditions, reviewable_conditions_2.join(' AND '))
 		
 		case filter
 		when 'by'
 			reviews_set = by_reviews_set
 		when 'to'
 			reviews_set = to_reviews_set - by_reviews_set
 		else
 			reviews_set = by_reviews_set | to_reviews_set
 		end
		reviews_set
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
