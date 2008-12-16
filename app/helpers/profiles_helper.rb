module ProfilesHelper

	def url_without_protocol(str)
		if !str.nil? && !str.blank?
			str_squish(str, 0).gsub("http://", '')
		else
			nil
		end
	end
	
	def url_with_protocol(str)
		"http://#{str_squish(str, 0)}"
	end
	
end
