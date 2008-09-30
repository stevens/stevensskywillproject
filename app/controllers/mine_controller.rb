class MineController < ApplicationController
	
	before_filter :protect
	before_filter :store_location_if_logged_in
	
	def overview
  	load_my_recipes_set
  	
  	load_my_reviews_set
	 	
	 	load_my_tags_set
	 	
	 	@user = @current_user
	 	
	 	info = "#{username_prefix(@current_user)}#{SITE_NAME_CN}"
		set_page_title(info)
		
		@show_todo = true
		
		show_sidebar
		
		render :template => "users/overview"
	end
	
	private
	
	def load_my_recipes_set
		@recipes_set = recipes_for(@current_user, nil)
		@recipes_set_count = @recipes_set.size
	end
	
	def load_my_reviews_set
		@reviews_set = reviews_for(@current_user, nil, nil)
		@reviews_set_count = @reviews_set.size
	end
	
	def load_my_tags_set
	  @tags_set = tags_for(@current_user, 'Recipe')
	  @tags_set_count = @tags_set.size
  	@custom_tags_set = tags_for(@current_user, 'Recipe', nil, TAG_COUNT_AT_LEAST, TAG_COUNT_AT_MOST, nil, order = 'count DESC')
	end

end
