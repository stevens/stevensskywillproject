# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	include AuthenticatedSystem
        include LoginSystem
	include ApplicationHelper
	include CodesHelper
	include ContactsHelper
	include CountersHelper
	include FavoritesHelper
	include FeedbacksHelper
	include HomepagesHelper
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
		if c == 'site'
			@current_tab_type = 'site'
		elsif c == 'mine' || a == 'mine'
			@current_tab_type = 'mine'
		elsif (c == 'users' && a != 'new') || params[:user_id] || c == 'contacts'
			@current_tab_type = 'user'
		elsif c == 'settings' || c == 'accounts'
			@current_tab_type = 'setting'
		elsif c == 'reviews' || c == 'taggings' || c == 'searchings' 
			@current_tab_type = params[:reviewable_type] || params[:taggable_type] || params[:searchable_type]
		elsif c == 'photos'
			@current_tab_type = params[:photoable_type] || @parent_type.downcase
		elsif c == 'recipes' || c == 'matches'
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
		# @system_notice = "号外1: <em>“蜂人(测试版)”栏目</em>新出锅, 大家可以<em>互相加为伙伴</em>啦！<br /><br/>
		#  									号外2: 大家可以到<em>帐户设置</em>里添加<em>自己的blog</em>啦！"
		@system_notice = "号外: <em>“蜂厨”</em>与新浪著名美食圈子<em>“美食·人生”</em>结成<em>友情合作伙伴</em>!"
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
		elsif params[:photo_id]
			@parent_type = 'Photo'
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
		elsif @parent_obj && @parent_obj.user
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
	
	def reg_homepage(homepageable, reg_type = 'create')
		content = "#{controller_name(type_for(homepageable))}/#{homepageable.id}"
		case reg_type
		when 'create'
			homepage = Homepage.new
			homepage.title = "#{controller_name(type_for(homepageable))} #{homepageable.id}"
			homepage.content = content
			homepage.save
		when 'update'
			if homepage = Homepage.find(:first, :conditions => { :content => content })
				homepage.save
			else
				homepage = Homepage.new
				homepage.title = "#{controller_name(type_for(homepageable))} #{homepageable.id}"
				homepage.content = content
				homepage.save
			end
		when 'destroy'
			if homepage = Homepage.find(:first, :conditions => { :content => content })
				homepage.destroy
			end
		end
	end
	
end
