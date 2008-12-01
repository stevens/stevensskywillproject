class MineController < ApplicationController
	
	before_filter :protect
	before_filter :store_location_if_logged_in
	before_filter :set_system_notice, :only => [:profile]
	
	def overview
		
	end
	
	def profile
		@user = @current_user
		
		load_notifications if @current_user
		
		@reviewable_type = 'Recipe'
		@favorable_type = 'Recipe'
		
  	load_recipes_set
  	# classify_recipes
  	load_reviews_set
  	load_favorites_set
  	# classify_favorite_statuses
	 	load_tags_set
	 	load_contactors_set
	 	
	 	info = "#{username_prefix(@current_user)}#{SITE_NAME_CN}"
		set_page_title(info)
		
		@show_todo = true
		
		show_sidebar
		
		render :template => "users/profile"
	end
	
	private
	
  def load_notifications(user = @current_user)
  	@notifications = []
  	contacts_set = contacts_for(user, contact_conditions('1', '1'))
  	if contacts_set.size > 0
  		@notifications << "你有#{contacts_set.size}个#{FRIEND_CN}请求"
  	end
  end
	
	def load_recipes_set(user = @current_user)
		@recipes_set = recipes_for(user)
		@recipes_set_count = @recipes_set.size
	end
	
	def load_reviews_set(user = @current_user)
		@reviews_set = filtered_reviews(user, @reviewable_type)
		@reviews_set_count = @reviews_set.size
	end
	
	def load_favorites_set(user = @current_user)
		@favorites_set = favorites_for(user)
		@favorites_set_count = @favorites_set.size
	end
	
	def load_tags_set(user = @current_user)
	  @tags_set = tags_for(user, 'Recipe', recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 100, 'count DESC, name')
	  @tags_set_count = @tags_set.size
	end
	
	def load_contactors_set(user = @current_user)
		@contactors_set = contactors_for(contacts_for(user, contact_conditions('1', '3'), 12, 'RAND()'))
		@contactors_set_count = @contactors_set.size
	end
	
	def classify_recipes
		@classified_recipes = classified_items(@recipes_set, 'from_type')
	end
	
	def classify_favorite_statuses
		@classify_favorite_statuses = classified_favorite_statuses(@favorites_set)
	end

end
