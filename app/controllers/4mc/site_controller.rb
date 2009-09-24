class SiteController < ApplicationController

	before_filter :clear_location_unless_logged_in, :only => [:index]
	before_filter :set_system_notice, :only => [:index]
	
	def index
		load_recipes_set
		### for love recipes function displaying
    load_love_recipes
    load_love_users
    ### end
		load_notifications if @current_user

    unless read_fragment(:controller => "site", :action => "index", :part => "rss")
      feed = rss_feed
      read_rss_items(feed, 5)
    end

    show_sidebar

		info = SLOGAN_CN
		set_page_title(info)

    #    puts "频道信息"
    #    puts "标题： #{channel.title}"
    #    puts "链接： #{channel.link}"
    #    puts "描述： #{channel.description}"
    #    puts "更新时间： #{channel.date}"
    #    puts "文章数量： #{items.size}"
    #
    #    for i in 0 ... items.size
    #      puts "----------- 文章#{i} -----------"
    #      puts "\t标题： #{items[i].title}"
    #      puts "\t链接： #{items[i].link}"
    #      puts "\t发表时间： #{items[i].date}"
    #      puts "\t内容： #{items[i].description}"
    #    end
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
    if @current_user
      begin
        recipes_set = CACHE.get('site_recipes_set')
      rescue Memcached::NotFound
        recipes_set = roles_recipes(user, '11', 30)
        CACHE.set('site_recipes_set',recipes_set,1800)
      end
    else
      begin
        recipes_set = CACHE.get('site_all_recipes_set')
      rescue Memcached::NotFound
        recipes_set = roles_recipes(user, '11', 30)
        CACHE.set('site_all_recipes_set',recipes_set,1800)
      end
    end 
    
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
  
  #### load love recipes of the user
  def load_love_recipes(user = nil)
    begin
      @love_recipes_set = CACHE.get('overview_love_recipes_set')
    rescue Memcached::NotFound
      @love_recipes_set = love_recipes(user, '21')
      CACHE.set('overview_love_recipes_set',@love_recipes_set)
    end
    #    @love_recipes_set = love_recipes(user, '21')
    @love_recipes_set_count = @love_recipes_set.size
  end
  
  def load_love_users(user = nil)
    begin
      @love_users_set = CACHE.get('overview_love_users_set')
    rescue Memcached::NotFound
      @love_users_set = love_users(user)
      CACHE.set('overview_love_users_set',@love_users_set)
    end
    #    @love_users_set = love_users(user)
    @love_users_set_count = @love_users_set.size
  end
  ### end
	
end
