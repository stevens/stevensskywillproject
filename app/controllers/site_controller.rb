class SiteController < ApplicationController
	
	def index
		set_page_title(HOME_CN)
	end
	
	def set_page_title(info)
		@page_title = page_title(info, '')
	end
	
end
