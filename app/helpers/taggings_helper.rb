module TaggingsHelper
  
	def tags_for(user, taggable_type, taggable_id = nil, at_least = 0, at_most = nil, limit = nil, order = 'name')
		if taggable_type
			if user || taggable_id
				if at_most
					model_for(taggable_type).tag_counts(:at_least => at_least, :at_most => at_most, :limit => limit, :order => order, 
																							:conditions => [tags_conditions(user, taggable_type, taggable_id)])
				else
					model_for(taggable_type).tag_counts(:at_least => at_least, :limit => limit, :order => order, 
																							:conditions => [tags_conditions(user, taggable_type, taggable_id)])	
				end
			else
				if at_most
					model_for(taggable_type).tag_counts(:at_least => at_least, :at_most => at_most, :limit => limit, :order => order)
				else
					model_for(taggable_type).tag_counts(:at_least => at_least, :limit => limit, :order => order)
				end
			end
		else
			if at_most
				Tag.counts(:at_least => at_least, :at_most => at_most, :limit => limit, :order => order)
			else
				Tag.counts(:at_least => at_least, :limit => limit, :order => order)
			end
		end
	end
	
  def tags_conditions(user, taggable_type, taggable_id)
  	conditions = []
  	conditions << "user_id = #{user.id}" if user
  	conditions << "#{controller_name_for(taggable_type)}.id = #{taggable_id}" if taggable_type && taggable_id
		conditions.join(" AND ")
  end
  
	def taggables_for(user, taggable_type, tag, conditions = nil, limit = nil, order = 'created_at DESC')
		if user
			conditions += " AND user_id = #{user.id}"
			model_for(taggable_type).find_tagged_with(tag, :limit => limit, :order => order, :conditions => [conditions])
		else
			model_for(taggable_type).find_tagged_with(tag, :limit => limit, :order => order, :conditions => [conditions])
		end
	end

end
