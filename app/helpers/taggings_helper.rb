module TaggingsHelper
	
	def tags_for(user = nil, taggable_type = nil, taggable_conditions = nil, limit = nil, order = 'name')
		conditions = []
		conditions << taggable_conditions if taggable_conditions
		conditions << "#{controller_name(taggable_type)}.user_id = #{user.id}" if user
		model_for(taggable_type).tag_counts(:limit => limit, :order => order, 
																			  :conditions => conditions.join(" AND "))
	end
  
	def taggables_for(user = nil, taggable_type = nil, tags = nil, taggable_conditions = nil, exclude = false, match_all = false, limit = nil, order = 'created_at DESC')
		conditions = []
		conditions << "#{controller_name(taggable_type)}.user_id = #{user.id}" if user
		conditions << taggable_conditions if taggable_conditions
		model_for(taggable_type).find_tagged_with(tags, :limit => limit, :order => order, 
																							:exclude => exclude, :match_all => match_all, 
																							:conditions => conditions.join(" AND "))
	end
	
	def formatted_tags(tags)
		' ' + tags.strip + ' '
	end
	
	def clean_tags(tags)
		tags = formatted_tags(tags)
		if !tags.strip.blank?
			tags_black_list = %w[ 美食 饮食 食物 吃 ]
			for bt in tags_black_list
				tags = tags.gsub(" #{bt} ", ' ')
			end
		else
			tags = ''
		end
		tags
	end

end
