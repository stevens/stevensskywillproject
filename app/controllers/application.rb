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
	include EntriesHelper
	include FavoritesHelper
	include FeedbacksHelper
	include HomepagesHelper
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
  
  # Protect a page from unauthorized access.
	def protect
		unless logged_in?
			flash[:notice] = "#{SORRY_CN}, 你还没有#{LOGIN_CN}#{SITE_NAME_CN}!"
			access_denied
		end
	end

	def set_current_tab
		c = params[:controller]
		a = params[:action]
		if c == 'site' && a == 'index'
			@current_tab_type = 'site'
		elsif c == 'mine' || a == 'mine'
			@current_tab_type = 'mine'
		elsif (c == 'users' && a != 'lost_activation' && a != 'resend_activation') || params[:user_id] || c == 'contacts'
			@current_tab_type = 'user'
		elsif c == 'settings' || c == 'accounts'
			@current_tab_type = 'setting'
		elsif @parent_obj && c == 'reviews'
			@current_tab_type = @parent_type.downcase
		elsif c == 'reviews' || c == 'taggings' || c == 'searchings' 
			@current_tab_type = params[:reviewable_type] || params[:taggable_type] || params[:searchable_type]
		elsif c == 'photos'
			@current_tab_type = params[:photoable_type] || @parent_type.downcase
		elsif c == 'matches' || c == 'entries' || c == 'match_actors' || c == 'winners'
			@current_tab_type = 'match'
		elsif c == 'recipes'
			@current_tab_type = c.singularize
		end
	end
	
	def set_page_title(info)
		@page_title = page_title(info, '')
	end
	
	def set_block_title(info)
		@block_title = info
	end
	
	def set_system_notice
#    @system_notice = "号外1: <em>“蜂人(测试版)”栏目</em>新出锅, 大家可以<em>互相加为伙伴</em>啦！<br /><br/>
#                      号外2: 大家可以到<em>帐户设置</em>里添加<em>自己的blog</em>啦！"
#    @system_notice = "号外: <em>“蜂厨”</em>与新浪著名美食圈子<em>“美食·人生”</em>结成<em>友情合作伙伴</em>!"
#    @system_notice = "号外: <em>金蜂·美食人生 大赛 (第一季) 即将开锅喽, 请密切关注比赛动态喔!</em>"
#    @system_notice = "号外: <em>金蜂·美食人生 大赛 (第一季) 明天凌晨零点正式开锅!</em>"
#    @system_notice = "<span class='bold'>金蜂·美食人生 大赛 (第一季) 正式开锅, 大伙儿快来参赛呵! <em class='l3' style='font-weight: bold;'>(报名和作品征集截止时间延后至2月15日)</em><br /><br />
#                      请要参赛的蜂友前往 <em class='l0'><a href='#{url_for(:controller => 'matches', :action => 'profile', :id => 1)}'>比赛页面</a></em> 报名参赛,
#                      并且查看 <em class='l2'><a href='#{url_for(:controller => 'matches', :action => 'show', :id => 1)}'>比赛详情</a></em> 和 <em class='l3'><a href='#{url_for(:controller => 'matches', :action => 'help')}'>比赛指南</a></em><br /><br />
#                      <em class='l1'><a href='#{url_for(:match_id => 1, :controller => 'entries', :action => 'index')}'>快来投票啦! 投票也有幸运奖呵!</a></em> 参赛的蜂友们快使用<em class='l3' style='font-weight: bold;'> 食谱分享 </em>为自己的作品拉票呵！</span>"
#    @system_notice = "<a href='#{url_for(:controller => 'matches', :action => 'profile', :id => 1)}'>金蜂·美食人生 大赛（第一季）</a> 快要结束啦，<em class='l3'>报名、征集和投票截止时间是2月15日（今天）23时59分59秒！</em><br /><br />
#                      请还没有提交参赛作品的选手们抓紧时间提交，<em class='l3'>报名并提交参赛作品的选手都有机会获得“参赛幸运奖”！</em><br />
#                      <em class='l3'>如果参赛作品有至少3位投票者投票，还可以参与“主奖项（金蜂奖、银蜂奖、铜蜂奖）”和“金蜂食单入围奖”的评选！</em><br />
#                      请蜂友们抓紧时间为你喜爱的作品投票，<em class='l3'>投票的蜂友都有机会获得“投票幸运奖”！</em>"
    @system_notice = "<a href='#{url_for(:controller => 'matches', :action => 'profile', :id => 1)}'>金蜂·美食人生 大赛（第一季）</a> <em class='l3'><a href='#{url_for(:match_id => 1, :controller => 'winners', :action => 'index')}'>获奖名单</a></em> 揭晓啦，恭喜获奖的作品和蜂友们！<br /><br />
                      蜂厨服务生将在2周左右时间内与获奖的蜂友取得联系，确认通讯地址并邮寄奖品..."
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
		elsif %w[mine].include?(params[:controller]) || (%w[mine new edit].include?(params[:action]) && !%w[settings accounts].include?(params[:controller]))
			@user_bar = @current_user
		elsif @parent_obj && @parent_obj.user && !%w[Match].include?(@parent_type)
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
  	dr_count = draft_recipes_set.size
  	publishable_recipes_set = []
  	for recipe in draft_recipes_set
  		publishable_recipes_set << recipe if recipe.publishable?
  	end
  	pr_count = publishable_recipes_set.size
		if dr_count > 0
			draft_recipes_url = url_for(:controller => 'recipes', :action => 'mine', :filter => 'draft')
			if pr_count > 0
				if pr_count == dr_count
					@notifications << [ "你有#{pr_count}#{unit_for('Recipe')}草稿#{RECIPE_CN}等待发布", draft_recipes_url ]
				else
					@notifications << [ "你有#{dr_count}#{unit_for('Recipe')}草稿#{RECIPE_CN}, 其中#{pr_count}#{unit_for('Recipe')}等待发布", draft_recipes_url ]
				end
			else
				@notifications << [ "你有#{dr_count}#{unit_for('Recipe')}草稿#{RECIPE_CN}", draft_recipes_url ]
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
	
end
