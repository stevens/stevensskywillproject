# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	include AuthenticatedSystem
  include LoginSystem #后台管理用
	
	include ApplicationHelper
	include AwardsHelper
	include CodesHelper
	include ContactsHelper
	include CountersHelper
  include CoursesHelper
	include EntriesHelper
	include FavoritesHelper
	include FeedbacksHelper
	include HomepagesHelper
  include MenusHelper
	include MatchActorsHelper
	include MatchesHelper
	include MineHelper
	include PasswordsHelper
	include PhotosHelper
	include ProfilesHelper
	include RatingsHelper
	include RecipesHelper
	include ReviewsHelper
	include SearchingsHelper
	include SessionsHelper
	include SettingsHelper
	include SiteHelper
	include SitemapHelper
	include StoriesHelper
	include SystemHelper
	include TaggingsHelper
	include UsersHelper
	include VotesHelper
	include WinnersHelper

  include ElectionsHelper #评选
  include NominationsHelper #提名
  include ElectAwardsHelper #评选奖项
  include ElectWinnersHelper #评选获奖
  include JudgeCategoriesHelper #评审类别
  include JudgesHelper #评审
  include PartnersHelper #合作伙伴
  include PartnershipCategoriesHelper #合作伙伴关系类别
  include PartnershipsHelper #合作伙伴关系
  include BallotsHelper #选票
  include BallotResultsHelper #选票结果
  
  helper :all # include all helpers, all the time
	
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'cc8183fbb5f7c6d11416a4cd6469fe64'

	before_filter :load_current_user
	before_filter :load_user
  before_filter :load_parent
  before_filter :load_self
  before_filter :load_self_urls
  before_filter :load_user_bar
	before_filter :set_current_tab
#	before_filter :set_system_notice
  
  # Protect a page from unauthorized access.
	def protect
		unless logged_in?
			flash[:notice] = "#{SORRY_CN}，你还没有#{LOGIN_CN}#{SITE_NAME_CN}！"
			access_denied
		end
	end

  # 管理员权限保护认证
  def admin_protect
    unless logged_in? && @current_user.is_role_of?('admin')
      flash[:notice] = "#{SORRY_CN}, 你没有访问权限！"
      redirect_to root_path
    end
  end

#  def rescue_errors
#    rescue_action_in_public CustomNotFoundError.new
#  end

  #出错时跳转到报错页面
  def rescue_action_in_public(exception)
    case exception
    when ActiveRecord::RecordNotFound, ActionController::RoutingError, NoMethodError, ActionController::UnknownController, ActionController::UnknownAction
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => "error", :status => "404"
    else
#      @message = exception
      render :file => "#{RAILS_ROOT}/public/500.html", :layout => "error", :status => "500"
    end
  end

  def local_request?
    return false
  end

	def set_current_tab
		c = params[:controller]
		a = params[:action]
    u = params[:user_id]
		if c == 'site' && a == 'index'
			@current_tab_type = 'site'
		elsif (@current_user && @user && @user == @current_user && (u || (c == 'users' && a == 'profile'))) || c == 'mine' || a == 'mine' || c == 'messages'
			@current_tab_type = 'mine'
		elsif u || (c == 'users' && a != 'lost_activation' && a != 'resend_activation') || c == 'contacts'
			@current_tab_type = 'user'
		elsif c == 'settings' || c == 'accounts' || c == 'profiles'
			@current_tab_type = 'setting'
		elsif @parent_obj && c == 'reviews'
			@current_tab_type = @parent_type.downcase
		elsif c == 'reviews' || c == 'taggings' || c == 'searchings' 
			@current_tab_type = params[:reviewable_type] || params[:taggable_type] || params[:searchable_type]
		elsif c == 'photos'
			@current_tab_type = params[:photoable_type] || @parent_type.downcase
		elsif c == 'matches' || c == 'entries' || c == 'match_actors' || c == 'winners'
			@current_tab_type = 'match'
    elsif c == 'menus' || c == 'courses'
      @current_tab_type = 'menu'
		elsif c == 'recipes'
			@current_tab_type = 'recipe'
    elsif c == 'elections' || params[:election_id]
      @current_tab_type = 'election'
    elsif c == 'partners'
      @current_tab_type = 'partner'
		end
	end
	
	def set_page_title(info)
		@page_title = page_title(info, '')
	end
	
	def set_block_title(info)
		@block_title = info
	end
	
	def set_system_notice
     @system_notice = system_notice
	end
	
	# def param_posted?(symbol)
	# 	request.post? and params[symbol]
	# end
	
	def load_current_user
		@current_user = User.find_by_id(session[:user_id])
  end
  
  def load_user
  	if params[:controller] == 'users' && params[:action] != 'activate'
  		@user_id = params[:id]
  	elsif params[:user_id]
	  	@user_id = params[:user_id]
	  end
  	if @user_id
	  	@user = User.find(@user_id)
	  	if @user
	  		@user_title = user_username(@user)
	  		@user_url = user_first_link(@user)
	  	end
	  end
  end
 
	def load_parent
		if params[:recipe_id]
			@parent_type = 'Recipe'
		elsif params[:match_id]
			@parent_type = 'Match'
		elsif params[:photo_id]
			@parent_type = 'Photo'
		elsif params[:entry_id]
			@parent_type = 'Entry'
    elsif params[:menu_id]
      @parent_type = 'Menu'
    elsif params[:election_id]
      @parent_type = 'Election'
    elsif params[:partner_id]
      @parent_type = 'Partner'
		end
		
		if @parent_type
			@parent_model = model_for(@parent_type)
	 		@parent_name = name_for(@parent_type)
	 		@parent_unit = unit_for(@parent_type)
			@parent_id = params[id_for(@parent_type).to_sym]
	 		@parent_obj = @parent_model.find(@parent_id) if @parent_id
	 		@parent_url = @parent_obj
 		end
	end
	
	def load_self
		@self_type = params[:controller].singularize.camelize
		
		if @self_type
			@self_model = model_for(@self_type)
			@self_name = name_for(@self_type)
			@self_unit = unit_for(@self_type)
			@self_id = params[:id]
			# if @self_model && @self_id
			# 	if self_obj = @self_model.find(@self_id)
			# 		@self_obj = self_obj
			# 	end
			# end
 		end
	end
  
  def load_self_urls
  	@selfs_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type}, nil)
  	@self_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type, :id => @self_id}, nil)
		@new_self_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type}, 'new')
		@edit_self_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type, :id => @self_id}, 'edit')
	end
	
	def load_user_bar
		if @user
			@user_bar = @user
		elsif %w[mine].include?(params[:controller]) || (%w[mine new edit].include?(params[:action]) && !%w[settings accounts profiles].include?(params[:controller]))
			@user_bar = @current_user
		elsif @parent_obj && @parent_obj.user && !%w[Match Election].include?(@parent_type)
			@user_bar = @parent_obj.user
		elsif params[:controller] == 'recipes' && params[:action] == 'show'
			@user_bar = @self_model.find(@self_id).user
		end
	end
	
	def load_current_filter
		@current_filter = params[:filter]
	end

  def clear_notice
		flash[:notice] = nil
	end
	
	def show_sidebar
		@show_sidebar = true
	end
	
	def clear_sidebar
		@show_sidebar = false
	end
	
	def store_location_if_logged_in
		store_location if logged_in?
	end
	
	def clear_location_unless_logged_in
		session[:return_to] = nil unless logged_in?
	end
	
	def log_count(countable)
		countable_type = type_for(countable)
		if counter = countable.counter
			current_total_view_count = counter.total_view_count || 0
			current_user_view_count = counter.user_view_count || 0
			current_self_view_count = counter.self_view_count || 0
		else
			counter = Counter.new
			counter.countable_type = countable_type
			counter.countable_id = countable.id			
			current_total_view_count = 0
			current_user_view_count = 0
			current_self_view_count = 0
		end
		
		counter.total_view_count = current_total_view_count + 1
		
		if @current_user
			if countable_type == 'User'
				if countable == @current_user
					counter.self_view_count = current_self_view_count + 1
				else
					counter.user_view_count = current_user_view_count + 1
				end
			else
				if countable.user == @current_user
					counter.self_view_count = current_self_view_count + 1
				else
					counter.user_view_count = current_user_view_count + 1
				end
			end
		end
		
		counter.update_attributes(params[:counter])
	end
	
  def load_notifications(user = @current_user)
  	@notifications = []
  	
  	# 提示需要处理的伙伴请求
  	contacts_set = contacts_for(user, contact_conditions('1', '1'))
  	if contacts_set.size > 0
  		requested_contacts_url = url_for(:controller => 'contacts', :action => 'mine', :filter => 'requested')
  		@notifications << [ "你有#{contacts_set.size}个#{FRIEND_CN}请求", requested_contacts_url ]
  	end
  	
  	# 提示未发布的食谱草稿
  	draft_recipes_set = user.recipes.find(:all, :conditions => { :is_draft => '1' })
  	draft_recipes_count = draft_recipes_set.size
  	publishable_recipes_set = []
  	for recipe in draft_recipes_set
  		publishable_recipes_set << recipe if recipe.publishable?
  	end
  	publishable_recipes_count = publishable_recipes_set.size
    recipe_unit = unit_for('Recipe')
		if draft_recipes_count > 0
			draft_recipes_url = url_for(:controller => 'recipes', :action => 'mine', :filter => 'draft')
			if publishable_recipes_count > 0
				if publishable_recipes_count == draft_recipes_count
					@notifications << [ "你有#{publishable_recipes_count}#{recipe_unit}草稿#{RECIPE_CN}等待发布", draft_recipes_url ]
				else
					@notifications << [ "你有#{draft_recipes_count}#{recipe_unit}草稿#{RECIPE_CN}, 其中#{publishable_recipes_count}#{recipe_unit}等待发布", draft_recipes_url ]
				end
			else
				@notifications << [ "你有#{draft_recipes_count}#{recipe_unit}草稿#{RECIPE_CN}", draft_recipes_url ]
			end
		end

  	# 提示未发布的餐单草稿
  	draft_menus_set = user.menus.find(:all, :conditions => { :is_draft => '1' })
  	draft_menus_count = draft_menus_set.size
  	publishable_menus_set = []
  	for menu in draft_menus_set
  		publishable_menus_set << menu if menu.publishable?
  	end
  	publishable_menus_count = publishable_menus_set.size
    menu_unit = unit_for('Menu')
		if draft_menus_count > 0
			draft_menus_url = url_for(:controller => 'menus', :action => 'mine', :filter => 'draft')
			if publishable_menus_count > 0
				if publishable_menus_count == draft_menus_count
					@notifications << [ "你有#{publishable_menus_count}#{menu_unit}草稿#{MENU_CN}等待发布", draft_menus_url ]
				else
					@notifications << [ "你有#{draft_menus_count}#{menu_unit}草稿#{MENU_CN}, 其中#{publishable_menus_count}#{menu_unit}等待发布", draft_menus_url ]
				end
			else
				@notifications << [ "你有#{draft_menus_count}#{menu_unit}草稿#{MENU_CN}", draft_menus_url ]
			end
		end
		
		# 提示未提交作品的比赛
		if @matches_set.nil? && @matches_set_count.nil?
			players = user.match_actors.find(:all, :order => 'RAND()', 
																			 :conditions => { :roles => '1' })
			@matches_set = joined_matches(players, '20')
			@matches_set_count = @matches_set.size
		end
		no_entry_matches_count = 0
		for match in @matches_set
			no_entry_matches_count += 1 if !match.player_has_entries?(user)
		end
		if no_entry_matches_count > 0
			no_entry_matches_url = url_for(:controller => 'matches', :action => 'mine')
			@notifications << [ "你在#{no_entry_matches_count}#{unit_for('Match')}正在参加的#{MATCH_CN}中还没有提交#{ENTRY_CN}", no_entry_matches_url ]
		end

    #提示未读新短信
    @unread_messages_set = @current_user.recieved_messages.find(:all, :conditions => "recipient_status = 1 and ifread = 1")
    if @unread_messages_set.size > 0
      unread_msg_url = url_for(:controller => 'messages', :action => 'index')
      @notifications << [ "你有#{@unread_messages_set.size}个新短信", unread_msg_url ]
    end

  end
  
  # 加载某个用户的比赛
	def load_user_matches(user)
		match_conditions = "#{match_accessible_conditions} AND #{match_status_conditions('doing', Time.now)}"
		@created_matches = user.matches.find(:all, :limit => 12, :order => 'RAND()', 
																				 :conditions => match_conditions)
		@created_matches_count = @created_matches.size
		match_actors_conditions = match_actor_role_conditions('player')
		@enrolled_matches = user_joined_matches(user, match_actors_conditions, match_conditions, 12, 'RAND()')
		@enrolled_matches_count = @enrolled_matches.size
		# @match_groups = []
		# username = user_username(user, false)
		# @match_groups << [ 'user_created_matches', "#{username}创建的...", @created_matches ] if @created_matches_count > 0
		# @match_groups << [ 'user_enrolled_matches', "#{username}参加的...", @enrolled_matches ] if @enrolled_matches_count > 0
		# @match_groups_count = @match_groups.size
	end

  # 读取RSS的Feed
  def read_rss_items(feed, limit)
    if feed && rss = rss_parser(feed)
      @rss_channel = rss.channel
      if limit && limit > 0
        @rss_items = rss.items[0..limit-1] # rss.channel.items亦可
      else
        @rss_items = rss.items
      end
    end
  end
	
end
