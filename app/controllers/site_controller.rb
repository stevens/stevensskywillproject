class SiteController < ApplicationController

	before_filter :clear_location_unless_logged_in, :only => [:index]
	before_filter :set_system_notice, :only => [:index]
	
	def index
		load_recipes_set
		
		load_notifications if @current_user
		
		info = SLOGAN_CN
		set_page_title(info)
	end
	
	def about
		info = "#{ABOUT_CN}#{SITE_NAME_CN}"
		set_page_title(info)
		set_block_title(info)
	end
	
	def help
		info = HELP_CN
		set_page_title(info)
		set_block_title(info)
	end
	
	def privacy
		info = PRIVACY_POLICY_CN
		set_page_title(info)
		set_block_title(info)
	end
	
	def terms
		info = TERMS_OF_SERVICE_CN
		set_page_title(info)
		set_block_title(info)
	end
	
	private
	
  def load_recipes_set(user = nil)
 		@recipes_set = recipes_for(user, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 10, 'RAND()')
  	@recipes_set_count = @recipes_set.size
  end
  
  def load_notifications(user = @current_user)
  	@notifications = []
  	contacts_set = contacts_for(user, contact_conditions('1', '1'))
  	if contacts_set.size > 0
  		@notifications << "你有#{contacts_set.size}个#{FRIEND_CN}请求"
  	end
  end
	
end
