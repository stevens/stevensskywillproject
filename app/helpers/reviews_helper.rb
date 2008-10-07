module ReviewsHelper

	def reviews_for(user, review_conditions = review_conditions, reviewable_type = nil, reviewable_conditions = nil, order = 'created_at DESC')
		conditions = []
		conditions << review_conditions
		if reviewable_type && reviewable_conditions
			join_table_name = controller_name(reviewable_type)
			joins = "JOIN #{join_table_name} ON reviews.reviewable_id = #{join_table_name}.id"
			conditions << reviewable_conditions
		end
		if user
			user.reviews.find(:all, :order => order, :joins => joins, 
												:conditions => [conditions.join(" AND ")])	
		else
			Review.find(:all, :order => order, :joins => joins, 
									:conditions => [conditions.join(" AND ")])
		end
	end
  
  def review_conditions(conds = {:reviewable_type => nil, :reviewable_id => nil, :created_at_from => nil, :created_at_to => nil})
  	conditions = ["reviews.review IS NOT NULL", 
  								"reviews.review <> ''"]
  	conditions << "reviews.reviewable_type = '#{conds[:reviewable_type]}'" if conds[:reviewable_type]
  	conditions << "reviews.reviewable_id = #{conds[:reviewable_id]}" if conds[:reviewable_id]
		conditions << "reviews.created_at >= '#{time_iso_format(conds[:created_at_from])}'" if conds[:created_at_from]
		conditions << "reviews.created_at <= '#{time_iso_format(conds[:created_at_to])}'" if conds[:created_at_to]
		conditions.join(" AND ")
  end

end
