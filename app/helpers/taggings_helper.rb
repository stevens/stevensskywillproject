module TaggingsHelper
	
	def tags_for(user = nil, taggable_type = nil, taggable_conditions = nil, limit = nil, order = 'name')
		conditions = []
		conditions << taggable_conditions if taggable_conditions
		conditions << "#{controller_name(taggable_type)}.user_id = #{user.id}" if user
		model_for(taggable_type).tag_counts(:limit => limit, :order => order, 
																			  :conditions => [conditions.join(" AND ")])
	end
  
	def taggables_for(user = nil, taggable_type = nil, tags = nil, taggable_conditions = nil, exclude = nil, match_all = nil, limit = nil, order = 'created_at DESC')
		conditions = []
		conditions << taggable_conditions if taggable_conditions
		conditions << "#{controller_name(taggable_type)}.user_id = #{user.id}" if user
		model_for(taggable_type).find_tagged_with(tags, :limit => limit, :order => order, 
																							:exclude => exclude, :match_all => match_all, 
																							:conditions => [conditions.join(" AND ")])
	end

end
