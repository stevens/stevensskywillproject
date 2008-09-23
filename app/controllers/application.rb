# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	include AuthenticatedSystem
  include ApplicationHelper
  include RecipesHelper
  include PhotosHelper
  include ReviewsHelper
  include TagsHelper
  include RatingsHelper
  include PasswordsHelper
  include SettingsHelper
  include CountersHelper
  
  helper :all # include all helpers, all the time
	
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'cc8183fbb5f7c6d11416a4cd6469fe64'

	before_filter :load_current_user
	before_filter :load_user
  before_filter :load_parent
  before_filter :load_self
  before_filter :load_self_urls
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
		elsif @self_type == 'cook' || (@user_id && @self_type == 'photo') || (@user_id && @self_type == 'review')
			@current_tab_type = 'cook'
		elsif c == 'mine' || (a == 'mine' && @self_type == 'photo') || (a == 'mine' && @self_type == 'review')
			@current_tab_type = 'mine'
		elsif @self_type == 'recipe' || (@parent_type == 'Recipe' && @self_type == 'photo') || (params[:reviewable_type] == 'recipe' && @self_type == 'review')
			@current_tab_type = 'recipe'
		elsif c == 'settings' || c == 'accounts'
			@current_tab_type = 'setting'
		end
		if @current_tab_type
			@current_tab_name = name_for(@current_tab_type)
		end
	end
	
	def set_page_title(info)
		@page_title = page_title(info, '')
	end
	
	def set_block_title(info)
		@block_title = info
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
  	if ("#{@url}".include? "#{'recipe'.pluralize}") && !("#{params[:controller]}".include? "#{'recipe'.pluralize}") && !("#{params[:id]}".include? "#{'recipe'.pluralize}")
  		@parent_type = 'Recipe'
  	elsif ("#{@url}".include? "#{'photo'.pluralize}") && !("#{params[:controller]}".include? "#{'photo'.pluralize}") && !("#{params[:id]}".include? "#{'photo'.pluralize}")
  		@parent_type = 'Photo'
  	end
		
		if @parent_type
			@parent_model = model_for(@parent_type)
	 		@parent_name = name_for(@parent_type)
	 		@parent_unit = unit_for(@parent_type)
			parent_id_sym = @parent_type.foreign_key.to_sym
			@parent_id = params[parent_id_sym]
	 		
	 		if @parent_id
	 			@parent_obj = @parent_model.find(@parent_id)
	 			if @parent_obj
			 		@parent_title = @parent_obj.title
			 		@parent_user = @parent_obj.user
			 		@parent_user_title = @parent_user.login if @parent_user
		 		end
	 			@parent_url = restfu_url_for(nil, nil, {:type => @parent_type, :id => @parent_id}, nil)
	 		end		
 		end
	end
	
	def load_self
		st = params[:controller]
		i = st.index('/')
		st = st[i+1..st.length-1] if i
		@self_type = st.singularize
		if @self_type
			@self_model = model_for(@self_type)
			@self_name = name_for(@self_type)
			@self_unit = unit_for(@self_type)
			@self_id = params[:id]
 		end
	end
  
  def load_self_urls
  	@selfs_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type}, nil)
  	@self_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type, :id => @self_id}, nil)
		@new_self_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type}, 'new')
		@edit_self_url = restfu_url_for(nil, {:type => @parent_type, :id => @parent_id}, {:type => @self_type, :id => @self_id}, 'edit')
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
	
	def items_paginate(items_set)
		@items = items_set.paginate :page => params[:page], 
 																 	 :per_page => LIST_ITEMS_COUNT_PER_PAGE_S		
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
