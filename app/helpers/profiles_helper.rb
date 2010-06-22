module ProfilesHelper

	def url_without_protocol(str)
		if !str.nil? && !str.blank?
			str_squish(str, 0).gsub("http://", '')
		else
			''
		end
	end
	
	def url_with_protocol(str)
		"http://#{str_squish(str, 0)}"
	end

  # 获取某个user的blog
  def profile_blog(user)
    if user && (profile = user.profile)
      if (blog = profile.blog) && !blog.blank?
        blog
      end
    end
  end
	
end
