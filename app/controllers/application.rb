# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	include AuthenticatedSystem
  include ApplicationHelper
  include RecipesHelper
  include PhotosHelper
  include ReviewsHelper
  include TaggingsHelper
  include SearchingsHelper
  include RatingsHelper
  include PasswordsHelper
  include SettingsHelper
  include CountersHelper
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
		elsif c == 'settings' || c == 'accounts'
			@current_tab_type = 'setting'
		elsif c == 'reviews' || c == 'photos' || c == 'taggings'
			@current_tab_type = params[:reviewable_type] || params[:photoable_type] || params[:taggable_type]
		else
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
		@system_notice = "号外: 可爱的蜂厨们, 人气食谱TOP10新鲜出炉了, 快去给你喜欢的食谱评分吧!<br /><br />
										 <em>提示: 由于存储提供商的服务器出现临时问题, 今天暂时不能上传食谱图片和头像, 实在不好意思!</em>"
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
		if counter = countable.counter
			current_total_view_count = counter.total_view_count ? counter.total_view_count : 0
			current_user_view_count = counter.user_view_count ? counter.user_view_count : 0
			current_self_view_count = counter.self_view_count ? counter.self_view_count : 0
		else
			counter = Counter.new
			counter.countable_type = type_for(countable)
			counter.countable_id = countable.id			
			current_total_view_count = 0
			current_user_view_count = 0
			current_self_view_count = 0
		end
		
		counter.total_view_count = current_total_view_count + 1
		
		if @current_user
			if countable.user == @current_user
				counter.self_view_count = current_self_view_count + 1
			else
				counter.user_view_count = current_user_view_count + 1
			end
		end
		
		counter.update_attributes(params[:counter])
	end
	
end
