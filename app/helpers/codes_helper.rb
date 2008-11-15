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

end
