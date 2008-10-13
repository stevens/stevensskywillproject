class SiteController < ApplicationController

	before_filter :clear_location_unless_logged_in, :only => [:index]
	before_filter :set_system_notice, :only => [:index]
	
	def index
		load_recipes_set
		
		set_page_title(HOME_CN)
	end
	
	private
	
  def load_recipes_set(user = nil)
 		@recipes_set = recipes_for(user, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 10, 'RAND()')
  	@recipes_set_count = @recipes_set.size
  end
	
end
