module HomepagesHelper

	def reg_homepage(homepageable, reg_type = 'create')
		content = "#{controller_name(type_for(homepageable))}/#{homepageable.id}"
		case reg_type
		when 'create'
			homepage = Homepage.new
			homepage.title = "#{controller_name(type_for(homepageable))} #{homepageable.id}"
			homepage.content = content
			homepage.save
		when 'update'
			if homepage = Homepage.find(:first, :conditions => { :content => content })
				homepage.save
			else
				homepage = Homepage.new
				homepage.title = "#{controller_name(type_for(homepageable))} #{homepageable.id}"
				homepage.content = content
				homepage.save
			end
		when 'destroy'
			if homepage = Homepage.find(:first, :conditions => { :content => content })
				homepage.destroy
			end
		end
	end

end
