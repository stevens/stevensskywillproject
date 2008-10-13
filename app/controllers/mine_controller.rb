class MineController < ApplicationController
	
	before_filter :protect
	before_filter :store_location_if_logged_in
	before_filter :set_system_notice, :only => [:overview]
	
	def overview
  	load_recipes_set
  	
  	load_reviews_set
	 	
	 	load_tags_set
	 	
	 	@user = @current_user
	 	
	 	info = "#{username_prefix(@current_user)}#{SITE_NAME_CN}"
		set_page_title(info)
		
		@show_todo = true
		
		show_sidebar
		
		render :template => "users/overview"
	end
	
	private
	
	def load_recipes_set(user = @current_user)
		@recipes_set = recipes_for(user)
		@recipes_set_count = @recipes_set.size
	end
	
	def load_reviews_set(user = @current_user)
		@reviews_set = reviews_for(user)
		@reviews_set_count = @reviews_set.size
	end
	
	def load_tags_set(user = @current_user)
	  @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
	  @tags_set_count = @tags_set.size
	end

end
