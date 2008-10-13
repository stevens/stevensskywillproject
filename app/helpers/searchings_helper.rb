module SearchingsHelper

	def keywords_line_to_search_id(keywords_line)
		if keywords_line && !text_squish(keywords_line).blank?
			keywords_line.gsub(' ', '+')
		else
			nil
		end
	end
	
	def search_id_to_keywords(search_id)
		if search_id && !search_id.strip.blank?
			search_id.split('+')
		else
			[]
		end
	end

	def keywords_to_conditions(keywords)
		conditions = []
		if keywords && keywords != []
			for keyword in keywords
				conditions << "title LIKE '%#{keyword}%'"
			end
		end
		conditions.join(' AND ')
	end
	
	def searchables_for(user = nil, searchable_type = nil, keywords = [], searchable_conditions = nil, exclude = nil, match_all = true, limit = nil, order = 'created_at DESC')
		conditions = [keywords_to_conditions(keywords)]
		conditions << "#{controller_name(searchable_type)}.user_id = #{user.id}" if user
		conditions << searchable_conditions if searchable_conditions
		
		searchables_set_1 = model_for(searchable_type).find(:all, :limit => limit, :order => order, 
																												:conditions => conditions.join(' AND '))
																												
		searchables_set_2 = taggables_for(user, searchable_type, keywords, searchable_conditions, exclude, match_all, limit, order)
		
		searchables_set = searchables_set_1 | searchables_set_2
		
		if limit
			searchables_set[0..limit-1].sort! {|a,b| b[:created_at] <=> a[:created_at]}
		else
			searchables_set.sort! {|a,b| b[:created_at] <=> a[:created_at]}
		end
	end
	
end
