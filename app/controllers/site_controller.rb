class SiteController < ApplicationController
	
	def index
		set_page_title(HOME_CN)
	end
	
	def search
  	if params[:search_type] && params[:search]
  		controller = params[:search_type].pluralize
	  	id = conditions_id(text_squish(params[:search]))
  		redirect_to :controller => controller, :action => 'search', :id => id
  	end
	end
	
end
