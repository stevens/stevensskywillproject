module CodesHelper

	def code_title(codeable_type, code)
		c = Code.find(:first, :conditions => {:codeable_type => codeable_type, :code => code})
		if c
			c.title
		else
			nil
		end
	end
	
	def codes_titles(codeable_type, codes)
		titles = []
		for code in codes
			titles << code_title(codeable_type, code)
		end
		titles
	end
	
	def codes_for(code_conditions, limit = nil, order = 'code')
		Code.find(:all, :limit => limit, :order => order, 
							:conditions => code_conditions)
	end
	
	def code_conditions(codeable_type, code = nil, title = nil, name = nil, created_at_from = nil, created_at_to = nil)
  	conditions = ["codes.code IS NOT NULL", 
  								"codes.code <> ''", 
  								"codes.codeable_type IS NOT NULL", 
  								"codes.codeable_type <> ''"]
  	conditions << "codes.codeable_type = '#{codeable_type}'" if codeable_type
  	conditions << "codes.code = '#{code}'" if code
  	conditions << "codes.title = '#{title}'" if title
  	conditions << "codes.name = '#{name}'" if name
		conditions << "codes.created_at >= '#{time_iso_format(created_at_from)}'" if created_at_from
		conditions << "codes.created_at < '#{time_iso_format(created_at_to)}'" if created_at_to
		conditions.join(" AND ")	
	end

end
