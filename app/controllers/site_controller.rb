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

  def linkus
    info = "链接#{SITE_NAME_CN}"
    set_page_title(info)
		set_block_title(info)

    show_sidebar
  end
	
	private
	
  def load_recipes_set(user = nil)
#    @recipes_set = recipes_for(user, recipe_conditions(recipe_photo_required_cond(user), recipe_status_cond(user), recipe_privacy_cond(user), recipe_is_draft_cond(user)), 10, 'RAND()')
#    @recipes_set_count = @recipes_set.size
    recipes_set = roles_recipes(user, '11', 30)
    @recipes_set = []
    for recipe in recipes_set
      if time_iso_format(recipe.created_at) > '2008-10-21 00:00:00'
        @recipes_set << recipe
        if @recipes_set.size >= 3
          break
        end
      end
    end
  end
	
end
