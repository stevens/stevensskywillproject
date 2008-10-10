class SiteController < ApplicationController

	before_filter :clear_location_unless_logged_in, :only => [:index]
	
	def index
		load_recipes_set
		
		set_page_title(HOME_CN)
	end
	
	def search
  	if params[:search_type] && params[:search]
  		controller = params[:search_type].pluralize
	  	id = conditions_id(text_squish(params[:search]))
  		redirect_to :controller => controller, :action => 'search', :id => id
  	end
	end
	
	private
	
  def load_recipes_set(user = nil)
 		@recipes_set = recipes_for(user, recipe_conditions({:photo_required => recipe_photo_required_cond(user), :status => recipe_status_cond(user), :privacy => recipe_privacy_cond(user), :is_draft => recipe_is_draft_cond(user)}), order = 'RAND()')
  	@recipes_set_count = @recipes_set.size
  end
	
end
